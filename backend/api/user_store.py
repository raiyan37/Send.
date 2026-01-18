from __future__ import annotations

import json
import threading
import uuid
from pathlib import Path
from typing import Any, Dict, Optional

_STORE_PATH = Path(__file__).with_name("user_store.json")
_LOCK = threading.Lock()


def _load_store() -> Dict[str, Any]:
    if not _STORE_PATH.exists():
        return {"users": {}, "tokens": {}}
    try:
        return json.loads(_STORE_PATH.read_text())
    except json.JSONDecodeError:
        return {"users": {}, "tokens": {}}


def _save_store(store: Dict[str, Any]) -> None:
    _STORE_PATH.write_text(json.dumps(store, indent=2, sort_keys=True))


def upsert_google_user(
    google_sub: str,
    email: str,
    given_name: Optional[str],
    family_name: Optional[str],
    picture_url: Optional[str],
) -> Dict[str, Any]:
    with _LOCK:
        store = _load_store()
        users = store.setdefault("users", {})

        existing = users.get(google_sub)
        if existing:
            existing["email"] = email
            existing["firstName"] = given_name or existing.get("firstName") or ""
            existing["lastName"] = family_name or existing.get("lastName") or ""
            existing["photoURL"] = picture_url or existing.get("photoURL")
            is_new = False
        else:
            existing = {
                "id": str(uuid.uuid4()),
                "googleSub": google_sub,
                "email": email,
                "firstName": given_name or "",
                "lastName": family_name or "",
                "photoURL": picture_url,
            }
            users[google_sub] = existing
            is_new = True

        token = _issue_token(store, existing["id"])
        _save_store(store)
        return {"user": existing, "token": token, "isNewUser": is_new}


def _issue_token(store: Dict[str, Any], user_id: str) -> str:
    tokens = store.setdefault("tokens", {})
    token = str(uuid.uuid4())
    tokens[token] = {"userId": user_id}
    return token
