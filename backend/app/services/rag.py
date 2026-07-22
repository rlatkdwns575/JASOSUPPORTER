"""RAG 컨텍스트 구성.

클라이언트가 경험 텍스트를 통째로 주입하던 방식을 대체한다.
- selected_experience_ids: 사용자가 문항에 명시적으로 고른 경험(정확 주입)
- Pinecone 검색: 쿼리와 유사한 top-k 경험(발견 주입)
- Pinecone 미설정 시: 로컬 저장소의 최근 경험으로 폴백
"""

from .. import store
from ..config import get_settings
from ..models import Experience
from . import embedding, pinecone_service


def _experience_facts(exp: Experience) -> str:
    lines = [f"- id: {exp.id}", f"  제목: {exp.title}", f"  유형: {exp.type}"]
    if exp.organization.strip():
        lines.append(f"  기관/소속: {exp.organization.strip()}")
    if exp.role.strip():
        lines.append(f"  역할: {exp.role.strip()}")
    if exp.situation.strip():
        lines.append(f"  상황: {exp.situation.strip()}")
    if exp.action.strip():
        lines.append(f"  행동: {exp.action.strip()}")
    if exp.result.strip():
        lines.append(f"  성과: {exp.result.strip()}")
    if exp.tech_stacks:
        lines.append("  기술 스택: " + ", ".join(exp.tech_stacks))
    return "\n".join(lines)


def _facts_from_metadata(metadata: dict) -> str:
    text = str(metadata.get("text") or "").strip()
    exp_id = str(metadata.get("experience_id") or metadata.get("id") or "")
    title = str(metadata.get("title") or "")
    header = f"- id: {exp_id} / 제목: {title}".rstrip()
    return f"{header}\n{text}" if text else header


def build_experience_context(
    *,
    user_id: str,
    query: str,
    selected_experience_ids: list[str],
) -> str:
    settings = get_settings()
    blocks: list[str] = []
    used_ids: set[str] = set()

    # 1) 사용자가 명시적으로 선택한 경험 (정확 주입)
    if selected_experience_ids:
        selected_docs = store.get_many(store.KIND_EXPERIENCE, user_id, selected_experience_ids)
        if selected_docs:
            facts = [_experience_facts(Experience.model_validate(doc)) for doc in selected_docs]
            used_ids.update(str(doc.get("id")) for doc in selected_docs)
            blocks.append("[선택한 Experience 카드 — 사실만 인용할 것]\n" + "\n".join(facts))

    # 2) Pinecone 유사도 검색 (발견 주입)
    retrieved: list[str] = []
    query_text = (query or "").strip()
    if query_text:
        vector = embedding.embed_text(query_text, is_query=True)
        if vector is not None and pinecone_service.is_enabled():
            matches = pinecone_service.query_experiences(user_id, vector, settings.rag_top_k)
            for metadata in matches:
                exp_id = str(metadata.get("experience_id") or metadata.get("id") or "")
                if exp_id and exp_id in used_ids:
                    continue
                used_ids.add(exp_id)
                retrieved.append(_facts_from_metadata(metadata))

    # 3) Pinecone 결과가 없으면 로컬 저장소 최근 경험으로 폴백
    if not retrieved:
        all_docs = store.list_docs(store.KIND_EXPERIENCE, user_id)
        all_docs.sort(key=lambda d: str(d.get("updatedAt") or ""), reverse=True)
        for doc in all_docs:
            exp_id = str(doc.get("id"))
            if exp_id in used_ids:
                continue
            used_ids.add(exp_id)
            retrieved.append(_experience_facts(Experience.model_validate(doc)))
            if len(retrieved) >= settings.rag_top_k:
                break

    if retrieved:
        blocks.append("[검색된 관련 경험 — 사실만 인용할 것]\n" + "\n".join(retrieved))

    return "\n\n".join(blocks).strip()
