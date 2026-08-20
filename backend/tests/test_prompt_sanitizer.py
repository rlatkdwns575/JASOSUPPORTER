"""prompt_sanitizer PII redaction 테스트."""

from app.services.prompt_sanitizer import redact_pii, sanitize_prompt


def test_redact_email() -> None:
    text = "연락처는 user@example.com 입니다."
    assert "[이메일]" in redact_pii(text)
    assert "user@example.com" not in redact_pii(text)


def test_redact_phone() -> None:
    text = "전화 010-1234-5678 로 연락"
    assert "[전화번호]" in redact_pii(text)


def test_sanitize_prompt_preserves_star_content() -> None:
    prompt = "결제 실패율 12%에서 3%로 낮췄다"
    assert sanitize_prompt(prompt) == prompt
