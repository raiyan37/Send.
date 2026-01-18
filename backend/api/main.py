import io
import os
import cv2
import imutils
import numpy as np

from dotenv import load_dotenv
from fastapi import FastAPI, UploadFile, HTTPException, status
from pydantic import BaseModel
from google.oauth2 import id_token
from google.auth.transport import requests
from starlette.responses import StreamingResponse

# Load environment variables from .env file
load_dotenv()

from src import config, image_utils, objects_detector
from src.aruco_marker import ArucoMarker
from src.route_generator import RouteGenerator
from . import session_store
from . import user_store

app = FastAPI(title="Climbing Crux Route Generator")


class ClimbEventBody(BaseModel):
    status: str
    attempts: int
    durationSeconds: int


class GoogleAuthBody(BaseModel):
    idToken: str


@app.post("/boulder/generate")
async def generate_boulder(file: UploadFile) -> StreamingResponse:
    """
    Generate a boulder route from an image
    """
    contents = await file.read()

    validate_file(file)

    np_img = np.frombuffer(contents, np.uint8)
    img = cv2.imdecode(np_img, cv2.IMREAD_COLOR)

    img = imutils.resize(img, width=1216)

    try:
        marker = ArucoMarker(config.MARKER_ARUCO_DICT, img, config.MARKER_PERIMETER_IN_CM)
    except ValueError:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No ArUco marker detected")

    detected_objects = objects_detector.detect(img)

    route_generator = RouteGenerator(
        img_width=img.shape[1],
        img_height=img.shape[0],
        marker=marker,
        detected_objects=detected_objects
    )

    try:
        positions = route_generator.generate_route(
            climber_height_in_cm=config.CLIMBER_HEIGHT_IN_CM,
            starting_steps_max_distance_from_ground_in_cm=config.STARTING_STEPS_MAX_DISTANCE_FROM_GROUND_IN_CM
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(exc)
        ) from exc

    for climber_position in positions:
        img = image_utils.draw_climber(
            img=img,
            climber=climber_position,
            draw_labels=False,
            draw_centers=False,
        )

    _, im_png = cv2.imencode(".png", img)
    return StreamingResponse(io.BytesIO(im_png.tobytes()), media_type="image/png")


@app.post("/api/users/{user_id}/sessions/today/start")
def start_today_session(user_id: str) -> dict:
    session_store.start_today_session(user_id)
    return session_store.get_today_session_stats(user_id)


@app.post("/api/users/{user_id}/sessions/today/end")
def end_today_session(user_id: str) -> dict:
    session_store.end_today_session(user_id)
    return session_store.get_today_session_stats(user_id)


@app.get("/api/users/{user_id}/sessions/today")
def get_today_session(user_id: str) -> dict:
    return session_store.get_today_session_stats(user_id)


@app.post("/api/users/{user_id}/sessions/today/climbs")
def add_today_climb(user_id: str, body: ClimbEventBody) -> dict:
    session_store.add_climb_event(
        user_id=user_id,
        status=body.status,
        attempts=body.attempts,
        duration_seconds=body.durationSeconds,
    )
    return session_store.get_today_session_stats(user_id)


@app.post("/api/auth/google")
def authenticate_google(body: GoogleAuthBody) -> dict:
    client_id = os.getenv("GOOGLE_OAUTH_IOS_CLIENT_ID")
    if not client_id:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Missing GOOGLE_OAUTH_IOS_CLIENT_ID",
        )

    try:
        payload = id_token.verify_oauth2_token(
            body.idToken,
            requests.Request(),
            audience=client_id,
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Google ID token",
        ) from exc

    email = payload.get("email", "")
    google_sub = payload.get("sub", "")
    if not email or not google_sub:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid token payload",
        )

    result = user_store.upsert_google_user(
        google_sub=google_sub,
        email=email,
        given_name=payload.get("given_name"),
        family_name=payload.get("family_name"),
        picture_url=payload.get("picture"),
    )

    user = result["user"]
    return {
        "user": {
            "id": user["id"],
            "email": user["email"],
            "firstName": user.get("firstName") or "",
            "lastName": user.get("lastName") or "",
            "photoURL": user.get("photoURL"),
        },
        "token": result["token"],
        "isNewUser": result["isNewUser"],
    }


def validate_file(file: UploadFile) -> None:
    if file.content_type not in config.ACCEPTED_MIME_TYPES:
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail="Unsupported file type",
        )

    real_file_size = 0
    for chunk in file.file:
        real_file_size += len(chunk)
        if real_file_size > config.MAXIMUM_FILE_SIZE:
            raise HTTPException(status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE, detail="Too large")
