# Rock Climber (Hackathon)

This repo contains:
- `backend/`: FastAPI service that takes a climbing wall image, detects holds (YOLO), calibrates scale using an ArUco marker, and returns an annotated PNG route overlay.
- `ios/`: SwiftUI iOS client (currently mostly UI scaffolding / placeholders).

## Backend quickstart

```bash
cd backend

# create + activate venv
python3 -m venv venv
source venv/bin/activate

# install deps
pip install -r requirements.txt

# run API
uvicorn api.main:app --host 0.0.0.0 --port 8000 --reload
```

Open `http://localhost:8000/docs`.

## Generate a route

```bash
curl -X POST "http://localhost:8000/boulder/generate" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@climbing_wall.jpg" \
  --output route.png
```

## ArUco calibration

The backend uses an ArUco marker to convert pixel distances into centimeters. Print the marker in `backend/resources/aruco_marker_5x5.png` and make sure it’s fully visible in the photo (avoid cutting it off at the image boundary).

## Tests

```bash
cd backend
pytest
```

## iOS app

The iOS client is configured via `ios/rock-climbing-app/Info.plist:1`:
- `BackendBaseURL` defaults to `http://localhost:8000` (works for the iOS Simulator if the backend is running on your Mac).
- For a physical device, set `BackendBaseURL` to `http://<your-mac-lan-ip>:8000` and run the backend with `--host 0.0.0.0`.
