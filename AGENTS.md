# AGENTS.md

## 프로젝트 이름

JasoSupporter

## 프로젝트 목적

JasoSupporter는 취업 준비생이 자신의 경험, 스펙, 프로젝트, 활동 내역을 구조화하고 이를 자기소개서, 포트폴리오, 면접 답변, README 초안, 기업별 지원 기록으로 재사용할 수 있도록 돕는 Flutter 기반 커리어 콘텐츠 관리 앱이다.

이 앱은 단순히 자기소개서를 대신 써주는 앱이 아니다.

핵심은 사용자의 경험을 구조화하고, 그 경험을 여러 취업 준비 산출물로 재활용할 수 있게 만드는 것이다.

## 핵심 개념

이 프로젝트의 중심 데이터는 Experience이다.

모든 주요 기능은 Experience를 기준으로 연결되어야 한다.

Experience
→ MasterEssay
→ PortfolioProject
→ InterviewAnswer
→ ApplicationRecord

즉, 사용자가 경험을 한 번 정리하면 다음 작업에 재사용할 수 있어야 한다.

- 마스터 자소서 작성
- 문항별 자기소개서 초안 생성
- 포트폴리오 프로젝트 설명 생성
- README.md 초안 생성
- 면접 예상 질문 생성
- 기업별 지원서 작성
- 제출본 관리

## 현재 앱의 주요 기능

현재 앱에는 다음 기능이 존재한다.

- 경험·스펙 모드
- 마스터 자소서 Q1~Q6 모드
- 포트폴리오 모드
- Gemini API 기반 AI 응답
- 모드별 시스템 프롬프트
- 파일 첨부
- 자료·복붙 입력 영역
- txt, pdf, 간이 docx 내보내기
- ProductSans 폰트
- 블루 계열 Material 3 디자인

## 개발 방향

현재 앱은 MVP 단계에서는 적절하지만, main.dart에 많은 책임이 집중되어 있다.

앞으로의 개발 방향은 다음과 같다.

1. main.dart를 앱 실행과 최상위 셸 중심으로 축소한다.
2. Gemini 호출은 GeminiService로 분리한다.
3. 프롬프트 조합은 PromptBuilder 또는 AI service 계층으로 분리한다.
4. 채팅 메시지, 경험, 자소서, 포트폴리오, 지원 기록은 domain model로 분리한다.
5. 경험·스펙 입력 폼은 Experience Card 생성/수정 화면으로 확장한다.
6. 마스터 자소서는 Experience id를 참조하도록 설계한다.
7. 포트폴리오는 PortfolioProject 모델과 연결한다.
8. 기업별 지원 관리는 ApplicationRecord 모델로 관리한다.
9. AI 답변은 단순 출력이 아니라 저장 가능한 결과물로 연결한다.

## 권장 아키텍처

feature-first 구조를 사용한다.

lib/
├─ main.dart
├─ app/
├─ core/
├─ domain/
├─ data/
└─ features/

각 폴더 역할은 다음과 같다.

### app/

앱 실행, 라우팅, 전역 Provider, 앱 셸을 담당한다.

### core/

공통 테마, 색상, 유틸, 공통 위젯, 에러 처리를 담당한다.

### domain/

비즈니스 모델, enum, repository interface를 담당한다.

### data/

GeminiService, ExportService, local storage, repository implementation을 담당한다.

### features/

화면 단위 기능을 담당한다.

features/
├─ home/
├─ experience/
├─ master_resume/
├─ portfolio/
├─ application_tracker/
└─ settings/

## 핵심 모델

반드시 다음 모델을 기준으로 확장한다.

### Experience

사용자의 경험 원천 데이터이다.

필수 필드:

- id
- title
- type
- period
- organization
- role
- situation
- task
- action
- result
- learned
- techStacks
- competencyTags
- evidenceLinks
- createdAt
- updatedAt

### SpecItem

자격증, 수상, 학력, 기술 스택 등 스펙 정보를 저장한다.

### MasterEssay

자소서 문항별 답변을 저장한다.

반드시 usedExperienceIds를 통해 Experience와 연결되어야 한다.

### EssayVersion

자소서 수정 이력을 저장한다.

### PortfolioProject

포트폴리오용 프로젝트 정보를 저장한다.

가능하면 Experience id와 연결한다.

### ApplicationRecord

기업별 지원 상태, 자소서, 사용 경험, 면접 기록을 저장한다.

### ChatMessage

AI 채팅 메시지를 저장한다.

### ChatRoom

모드별 채팅 기록을 관리한다.

## AI 기능 원칙

AI 기능의 목적은 단순 대필이 아니다.

AI는 다음 작업을 돕는다.

1. 경험 구조화
2. STAR 변환
3. 역량 태그 추천
4. 자소서 문항 분석
5. 경험과 문항 매칭
6. 자소서 초안 생성
7. 자소서 첨삭
8. 포트폴리오 설명 생성
9. README 초안 생성
10. 면접 예상 질문 생성

## AI 금지사항

AI는 다음을 절대 하면 안 된다.

- 사용자가 입력하지 않은 경험 생성
- 허위 경력 생성
- 허위 수치 생성
- 성과 과장
- 기업명 무단 삽입
- 직무 경험 조작
- 면접에서 방어할 수 없는 표현 생성
- 키워드만 나열하는 자소서 생성
- 사용자의 경험을 앱 목적과 무관하게 변형

## 프롬프트 작성 원칙

모든 AI 프롬프트는 다음 기준을 따른다.

- 사용자의 원본 경험을 기반으로 한다.
- 부족한 정보가 있으면 보완 질문을 제안한다.
- 없는 사실을 만들지 않는다.
- 결과물은 문항 의도와 연결한다.
- 자소서는 상황, 행동, 결과, 배운 점이 드러나야 한다.
- 포트폴리오는 문제 정의, 역할, 구현 과정, 결과, 한계, 개선 방향이 드러나야 한다.
- 면접 답변은 과장보다 방어 가능성을 우선한다.

## UI/UX 원칙

앱은 취업 준비생이 장기간 사용하는 생산성 앱처럼 보여야 한다.

디자인 원칙:

- 카드 기반 레이아웃
- 블루 계열 메인 컬러
- 한국어 UI
- 명확한 작업 흐름
- 너무 많은 입력 필드를 한 번에 노출하지 않기
- 경험, 자소서, 포트폴리오, 지원 관리를 시각적으로 구분
- AI 답변은 단순 채팅 출력이 아니라 저장 가능한 결과물로 연결

권장 주요 화면:

- 홈 대시보드
- 경험 카드 목록
- 경험 상세/수정
- 스펙 관리
- 마스터 자소서 워크스페이스
- 포트폴리오 빌더
- 지원 관리
- 설정

## 디자인 개선 방향

현재 앱은 채팅형 도구 느낌이 강하다.

앞으로는 다음 구조로 개선한다.

홈 대시보드
→ 경험 카드 관리
→ 마스터 자소서 작성
→ 포트폴리오 생성
→ 기업별 지원 관리

기능별 색상 방향:

- 경험·스펙: Blue
- 마스터 자소서: Indigo
- 포트폴리오: Teal
- 지원 관리: Amber
- 첨삭/경고: Red
- 완료/성과: Green
- AI 코칭: Purple

## 코드 작성 규칙

- Flutter 코드에서는 const 생성자를 최대한 사용한다.
- UI와 비즈니스 로직을 분리한다.
- 화면에서 직접 Gemini API를 호출하지 않는다.
- 화면에서 직접 저장소를 호출하지 않는다.
- 화면 → Provider/Controller → Service/Repository → Data Source 흐름을 따른다.
- API Key는 코드에 직접 작성하지 않는다.
- 하드코딩된 색상은 AppColors 또는 Theme을 사용한다.
- 한 파일이 지나치게 길어지면 기능 단위로 분리한다.
- 기존 기능을 깨뜨리는 대규모 변경은 피한다.
- 리팩토링은 작은 단위로 진행한다.

## main.dart 관련 규칙

main.dart는 다음 책임만 갖는 것을 목표로 한다.

- WidgetsFlutterBinding 초기화
- 환경 변수 로드
- 앱 실행
- 최상위 App 위젯 호출

다음 책임은 main.dart에서 분리해야 한다.

- Gemini API 호출
- 파일 첨부 처리
- 프롬프트 조합
- 채팅 메시지 관리
- 모드별 상태 관리
- Export 처리
- 복잡한 UI 컴포넌트

## 테스트 원칙

핵심 로직에는 테스트를 작성한다.

우선 테스트 대상:

- Experience 생성/수정
- STAR 변환 로직
- 자소서 글자 수 카운트
- 프롬프트 빌드 로직
- ExportService
- 입력값 validation
- AI 응답 후 저장 가능한 결과물 변환

작업 후 가능하면 다음 명령을 확인한다.

flutter analyze
flutter test

## 금지사항

다음 작업은 사용자의 명시적 요청 없이 하지 않는다.

- 앱 목적 변경
- Experience 중심 구조 제거
- 상태관리 방식 대규모 변경
- UI 언어를 영어로 변경
- Gemini API 구조 제거
- 기존 모드 삭제
- 데이터 모델 필드명 임의 변경
- API Key 하드코딩
- 기존 파일 대량 삭제
- 실제 기능을 깨뜨리는 리팩토링

## 작업 보고 형식

작업 후에는 다음 형식으로 보고한다.

1. 작업 요약
2. 생성한 파일
3. 수정한 파일
4. 구조 변경 내용
5. 테스트 여부
6. 남은 문제
7. 다음 작업 제안
