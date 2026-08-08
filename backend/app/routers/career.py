"""보조 커리어 엔티티 CRUD. Flutter 저장소 인터페이스를 그대로 지원한다.

각 엔티티는 유연한 JSON dict 로 저장한다(Flutter toJson/fromJson 과 동일 형태).
"""

from fastapi import APIRouter, Body, Depends, HTTPException, Query

from .. import store
from ..deps import get_user_id

router = APIRouter(tags=["career"])


def _require_id(payload: dict) -> str:
    doc_id = str(payload.get("id") or "").strip()
    if not doc_id:
        raise HTTPException(status_code=400, detail="id is required")
    return doc_id


# --- Spec items ---
@router.get("/spec-items")
def list_spec_items(user_id: str = Depends(get_user_id)) -> list[dict]:
    return store.list_docs(store.KIND_SPEC_ITEM, user_id)


@router.post("/spec-items")
def save_spec_item(payload: dict = Body(...), user_id: str = Depends(get_user_id)) -> dict:
    doc_id = _require_id(payload)
    return store.upsert(store.KIND_SPEC_ITEM, user_id, doc_id, payload)


@router.delete("/spec-items/{doc_id}")
def delete_spec_item(doc_id: str, user_id: str = Depends(get_user_id)) -> dict:
    store.delete_doc(store.KIND_SPEC_ITEM, user_id, doc_id)
    return {"ok": True}


# --- Master essays ---
@router.get("/master-essays")
def list_master_essays(user_id: str = Depends(get_user_id)) -> list[dict]:
    return store.list_docs(store.KIND_MASTER_ESSAY, user_id)


@router.get("/master-essays/{doc_id}")
def get_master_essay(doc_id: str, user_id: str = Depends(get_user_id)) -> dict:
    doc = store.get_doc(store.KIND_MASTER_ESSAY, user_id, doc_id)
    if doc is None:
        raise HTTPException(status_code=404, detail="MasterEssay not found")
    return doc


@router.post("/master-essays")
def save_master_essay(payload: dict = Body(...), user_id: str = Depends(get_user_id)) -> dict:
    doc_id = _require_id(payload)
    return store.upsert(store.KIND_MASTER_ESSAY, user_id, doc_id, payload)


@router.delete("/master-essays/{doc_id}")
def delete_master_essay(doc_id: str, user_id: str = Depends(get_user_id)) -> dict:
    store.delete_doc(store.KIND_MASTER_ESSAY, user_id, doc_id)
    # 연결된 버전도 함께 정리한다.
    versions = store.list_docs(store.KIND_ESSAY_VERSION, user_id)
    for version in versions:
        if str(version.get("masterEssayId")) == doc_id:
            store.delete_doc(store.KIND_ESSAY_VERSION, user_id, str(version.get("id")))
    return {"ok": True}


# --- Essay versions ---
@router.get("/essay-versions")
def list_essay_versions(
    master_essay_id: str = Query(..., alias="masterEssayId"),
    user_id: str = Depends(get_user_id),
) -> list[dict]:
    docs = store.list_docs(store.KIND_ESSAY_VERSION, user_id)
    return [doc for doc in docs if str(doc.get("masterEssayId")) == master_essay_id]


@router.post("/essay-versions")
def save_essay_version(payload: dict = Body(...), user_id: str = Depends(get_user_id)) -> dict:
    doc_id = _require_id(payload)
    return store.upsert(store.KIND_ESSAY_VERSION, user_id, doc_id, payload)


@router.delete("/essay-versions/{doc_id}")
def delete_essay_version(doc_id: str, user_id: str = Depends(get_user_id)) -> dict:
    store.delete_doc(store.KIND_ESSAY_VERSION, user_id, doc_id)
    return {"ok": True}


# --- Portfolio projects ---
@router.get("/portfolio-projects")
def list_portfolio_projects(user_id: str = Depends(get_user_id)) -> list[dict]:
    return store.list_docs(store.KIND_PORTFOLIO, user_id)


@router.post("/portfolio-projects")
def save_portfolio_project(payload: dict = Body(...), user_id: str = Depends(get_user_id)) -> dict:
    doc_id = _require_id(payload)
    return store.upsert(store.KIND_PORTFOLIO, user_id, doc_id, payload)


@router.delete("/portfolio-projects/{doc_id}")
def delete_portfolio_project(doc_id: str, user_id: str = Depends(get_user_id)) -> dict:
    store.delete_doc(store.KIND_PORTFOLIO, user_id, doc_id)
    return {"ok": True}


# --- Application records ---
@router.get("/application-records")
def list_application_records(user_id: str = Depends(get_user_id)) -> list[dict]:
    return store.list_docs(store.KIND_APPLICATION, user_id)


@router.post("/application-records")
def save_application_record(payload: dict = Body(...), user_id: str = Depends(get_user_id)) -> dict:
    doc_id = _require_id(payload)
    return store.upsert(store.KIND_APPLICATION, user_id, doc_id, payload)


@router.delete("/application-records/{doc_id}")
def delete_application_record(doc_id: str, user_id: str = Depends(get_user_id)) -> dict:
    store.delete_doc(store.KIND_APPLICATION, user_id, doc_id)
    return {"ok": True}


# --- Interview answers ---
@router.get("/interview-answers")
def list_interview_answers(user_id: str = Depends(get_user_id)) -> list[dict]:
    return store.list_docs(store.KIND_INTERVIEW_ANSWER, user_id)


@router.post("/interview-answers")
def save_interview_answer(payload: dict = Body(...), user_id: str = Depends(get_user_id)) -> dict:
    doc_id = _require_id(payload)
    return store.upsert(store.KIND_INTERVIEW_ANSWER, user_id, doc_id, payload)


@router.delete("/interview-answers/{doc_id}")
def delete_interview_answer(doc_id: str, user_id: str = Depends(get_user_id)) -> dict:
    store.delete_doc(store.KIND_INTERVIEW_ANSWER, user_id, doc_id)
    return {"ok": True}
