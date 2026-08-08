"""회원가입·로그인·내 정보."""

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field

from ..deps import get_user_id
from ..services import auth_service

router = APIRouter(prefix="/auth", tags=["auth"])


class AuthCredentials(BaseModel):
    email: str = Field(min_length=3)
    password: str = Field(min_length=8)


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: str
    email: str


@router.post("/register", response_model=TokenResponse)
def register(body: AuthCredentials) -> TokenResponse:
    try:
        user = auth_service.register_user(body.email, body.password)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    token = auth_service.create_access_token(user_id=user.id, email=user.email)
    return TokenResponse(access_token=token, user_id=user.id, email=user.email)


@router.post("/login", response_model=TokenResponse)
def login(body: AuthCredentials) -> TokenResponse:
    user = auth_service.authenticate(body.email, body.password)
    if user is None:
        raise HTTPException(status_code=401, detail="이메일 또는 비밀번호가 올바르지 않습니다.")
    token = auth_service.create_access_token(user_id=user.id, email=user.email)
    return TokenResponse(access_token=token, user_id=user.id, email=user.email)


@router.get("/me")
def me(user_id: str = Depends(get_user_id)) -> dict:
    user = auth_service.get_user_by_id(user_id)
    if user is None:
        # soft identity (개발 폴백)일 수 있음
        return {"user_id": user_id, "email": None, "auth": "soft"}
    return {"user_id": user.id, "email": user.email, "auth": "jwt"}
