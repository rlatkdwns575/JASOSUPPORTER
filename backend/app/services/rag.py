"""경험 컨텍스트 구성.

벡터 DB 없이 로컬 store만 사용한다.
- selected_experience_ids: 사용자가 문항에 고른 경험(정확 주입)
- 미선택 시: 로컬 저장소의 최근 경험 top-k(폴백)
"""

from .. import store
from ..config import get_settings
from ..logging_config import get_logger
from ..models import Experience

logger = get_logger(__name__)


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


def build_selected_experience_context(
    *,
    user_id: str,
    selected_experience_ids: list[str],
) -> str:
    """선택 경험만 주입한다."""
    if not selected_experience_ids:
        return ""
    selected_docs = store.get_many(store.KIND_EXPERIENCE, user_id, selected_experience_ids)
    if not selected_docs:
        return ""
    facts = [_experience_facts(Experience.model_validate(doc)) for doc in selected_docs]
    return "[선택한 Experience 카드 — 사실만 인용할 것]\n" + "\n".join(facts)


def build_experience_context(
    *,
    user_id: str,
    query: str,
    selected_experience_ids: list[str],
) -> str:
    """선택 경험 + (없을 때) 최근 경험 폴백."""
    _ = query  # 향후 로컬 키워드 필터용; 현재는 미사용
    settings = get_settings()
    blocks: list[str] = []
    used_ids: set[str] = set()

    if selected_experience_ids:
        selected_docs = store.get_many(store.KIND_EXPERIENCE, user_id, selected_experience_ids)
        if selected_docs:
            facts = [_experience_facts(Experience.model_validate(doc)) for doc in selected_docs]
            used_ids.update(str(doc.get("id")) for doc in selected_docs)
            blocks.append("[선택한 Experience 카드 — 사실만 인용할 것]\n" + "\n".join(facts))

    retrieved: list[str] = []
    if not blocks:
        logger.info("rag local recent fallback user_id=%s", user_id)
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
        blocks.append("[최근 경험 — 사실만 인용할 것]\n" + "\n".join(retrieved))

    return "\n\n".join(blocks).strip()
