# JasoSupporter

JasoSupporter는 취업 준비생이 자신의 경험·스펙을 구조화하고, 이를 마스터 자소서, 포트폴리오, 면접 답변, README 초안, 지원 기록으로 재사용할 수 있도록 돕는 Flutter 기반 커리어 콘텐츠 워크스페이스입니다.

패키지 이름은 `chatgptmini`이고, 앱 표시 이름은 **JasoSupporter**입니다. Google **Gemini API**를 사용합니다.

## Product Direction

JasoSupporter는 단순 자소서 생성기가 아니라 **Experience Card 중심의 커리어 지식 베이스**를 목표로 합니다.

```text
Experience Card
-> Master Essay
-> Portfolio Project
-> Interview Answer
-> Application Record
```

핵심 원칙:

- 사용자가 입력한 사실을 기반으로만 AI가 정리·변환합니다.
- 경험은 한 번 구조화하고 여러 산출물에 재사용합니다.
- UI는 한국어, ProductSans, 블루/틸 계열 디자인을 유지합니다.
- 채팅은 보조 도구이고, 중심은 구조화된 경험 카드와 작업 화면입니다.

## 주요 기능

| 모드 | 설명 |
|------|------|
| **경험·스펙** | 학적, 전공, 학점, 자격증, 동아리, 교내 활동, 인턴, 아르바이트, 공모전, 부트캠프, 어학연수 등을 구조화해 입력합니다. 여러 활동을 카드처럼 추가할 수 있고, `경험 카드로 저장`을 통해 로컬 저장소에 저장합니다. |
| **마스터 자소서** | 지원 희망 직무와 Q1~Q6 문항별 초안을 작성합니다. 저장된 Experience 카드를 문항별로 선택해 AI 초안과 export metadata에 연결합니다. 문항별/전체 초고 버전 저장·불러오기를 지원합니다. |
| **포트폴리오** | 저장된 경험과 사용자 입력을 바탕으로 Figma 중심 포트폴리오 목차와 카피 구성을 돕습니다. |

공통 기능:

- 모드별 채팅 기록 분리
- Gemini 스트리밍 응답
- PDF·이미지 첨부 지원
- 하단 `자료·복붙` 패널
- TXT / PDF / 간이 DOCX export
- 로컬 JSON 기반 Experience, SpecItem, MasterEssay, EssayVersion 저장
- 카드형 UI, 공통 테마 토큰, 블루/틸 Material 3 디자인

## 최근 구조 개선

- `main.dart`에서 Gemini, 첨부, 프롬프트, export, 채팅 흐름 일부를 서비스/컨트롤러로 분리했습니다.
- `Experience`, `SpecItem`, `MasterEssay`, `EssayVersion` 등 도메인 모델을 추가했습니다.
- `JsonCareerRepository`로 로컬 JSON 저장소를 도입했습니다.
- `core/theme`와 `core/widgets`를 추가해 테마와 공통 UI 컴포넌트를 분리했습니다.
- 흰 화면 방지를 위해 API 키 누락 시 안내 화면을 띄우고, 초기 로드 실패가 앱 렌더링을 막지 않도록 처리했습니다.

## 기술 스택

- Flutter / Dart SDK `^3.9.2`
- `flutter_gemini` — Gemini API 스트리밍 응답
- `flutter_dotenv` — `assets/.env` API 키 로드
- `file_picker`, `mime` — PDF·이미지 첨부 선택 및 검증
- `path_provider` — 로컬 JSON 저장소 경로
- `pdf`, `share_plus`, `archive` — TXT/PDF/DOCX export 및 공유

Gemini 호출은 `lib/data/services/gemini_service.dart`의 `GeminiService`를 통해 수행됩니다.

## 실행 방법

1. 의존성 설치

   ```bash
   flutter pub get
   ```

2. API 키 설정

   `assets/.env` 파일을 만들고 다음 값을 넣습니다.

   ```env
   GOOGLE_API_KEY=여기에_키
   ```

   API 키 파일은 커밋하지 마세요. 키가 없거나 `.env` 로드에 실패하면 앱은 흰 화면으로 죽지 않고 안내 화면을 표시합니다.

3. 실행

   ```bash
   flutter run
   ```

   Chrome으로 실행하려면:

   ```bash
   flutter run -d chrome
   ```

4. 검증

   ```bash
   flutter analyze
   flutter test
   ```

## 프로젝트 구조

```text
lib/
├─ main.dart
├─ app/
├─ core/
│  ├─ theme/
│  └─ widgets/
├─ data/
│  ├─ local/
│  └─ services/
├─ domain/
│  ├─ enums/
│  ├─ models/
│  └─ repositories/
└─ features/
   ├─ experience/
   │  └─ experience_spec_form.dart
   ├─ home/
   ├─ master_resume/
   ├─ portfolio/
   ├─ chat/
   └─ settings/
```

주요 역할:

| 경로 | 역할 |
|------|------|
| `main.dart` | 앱 실행·바인딩 초기화 |
| `app/` | 라우팅, 셸, 전역 액션 |
| `core/theme` | 앱 색상 토큰과 `AppTheme.light()` |
| `core/widgets` | 카드, 섹션 헤더, 빈 상태, 채팅/입력 공통 위젯 |
| `domain/models` | Experience 중심 도메인 모델 |
| `data/services` | Gemini, 첨부, 프롬프트 생성 서비스 |
| `data/local` | 로컬 JSON 저장소 |
| `features/experience` | 경험 폼·카드·STAR 파싱 |
| `features/chat` | 채팅 turn 구성과 AI stream 요청 준비 |

## AI Policy

AI는 사용자가 제공한 경험·스펙 사실을 바탕으로 구조화, 요약, 재배열, 문장화합니다. 없는 수치, 성과, 직책, 경험을 만들어내면 안 됩니다. 정보가 부족하면 질문하거나 “추가 확인 필요”로 남겨야 합니다.

## README 유지 관리

앱 기능, 저장 모델, 환경 변수, 폴더 구조, 의존성이 바뀌면 이 README의 주요 기능, 실행 방법, 프로젝트 구조를 실제 코드와 맞춰 업데이트하세요.

## 라이선스·상표

내부/개인 프로젝트(`publish_to: 'none'`) 기준으로 작성되었습니다. ProductSans 폰트는 배포 시 라이선스를 확인하세요.
