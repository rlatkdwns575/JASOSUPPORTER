"""코치 채팅방 영속화 (모드별 메시지)."""

from fastapi import APIRouter, Body, Depends, HTTPException

from .. import store
from ..deps import get_user_id

router = APIRouter(prefix="/chat-rooms", tags=["chat"])


def _require_id(payload: dict) -> str:
    doc_id = str(payload.get("id") or "").strip()
    if not doc_id:
        raise HTTPException(status_code=400, detail="id is required")
    return doc_id


@router.get("")
def list_chat_rooms(user_id: str = Depends(get_user_id)) -> list[dict]:
    return store.list_docs(store.KIND_CHAT_ROOM, user_id)


@router.get("/{doc_id}")
def get_chat_room(doc_id: str, user_id: str = Depends(get_user_id)) -> dict:
    doc = store.get_doc(store.KIND_CHAT_ROOM, user_id, doc_id)
    if doc is None:
        raise HTTPException(status_code=404, detail="ChatRoom not found")
    return doc


@router.post("")
def save_chat_room(payload: dict = Body(...), user_id: str = Depends(get_user_id)) -> dict:
    doc_id = _require_id(payload)
    return store.upsert(store.KIND_CHAT_ROOM, user_id, doc_id, payload)


@router.delete("/{doc_id}")
def delete_chat_room(doc_id: str, user_id: str = Depends(get_user_id)) -> dict:
    store.delete_doc(store.KIND_CHAT_ROOM, user_id, doc_id)
    return {"ok": True}
