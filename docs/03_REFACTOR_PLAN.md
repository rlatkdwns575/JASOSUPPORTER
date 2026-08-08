# 03. Refactor Plan

## Current Structure Analysis

`main.dart` currently carries too many responsibilities:

- App shell and theme creation
- Mode switching
- Split-pane layout
- Chat room state
- Gemini initialization and response generation
- Prompt/context assembly
- File picking and attachment validation
- Message sending
- Export orchestration
- Master resume request construction
- Experience form integration

This works for a small prototype, but it makes feature growth risky.

## Target Folder Direction

```text
lib/
├─ main.dart
├─ app/
│  ├─ app.dart
│  ├─ router.dart
│  └─ providers.dart
├─ core/
│  ├─ constants/
│  ├─ theme/
│  ├─ widgets/
│  ├─ utils/
│  └─ errors/
├─ domain/
│  ├─ models/
│  ├─ enums/
│  └─ repositories/
├─ data/
│  ├─ services/
│  ├─ local/
│  └─ repositories/
└─ features/
   ├─ home/
   ├─ experience/
   ├─ master_resume/
   ├─ portfolio/
   ├─ application_tracker/
   └─ settings/
```

## Incremental Refactor Order

1. Move colors/theme into `core/theme`.
2. Move shared widgets such as brand mark, split header, chat bubbles, attachment panel, and input bar into `core/widgets` or feature widgets.
3. Move `ChatMessage` and `ChatRoom` into `domain/models`.
4. Create `data/services/GeminiService` and move Gemini initialization/generation behind it.
5. Create `data/services/AttachmentService` for file picking and validation.
6. Create prompt builders per feature.
7. Convert `ExperienceSpecForm` output from prompt text into `Experience` and `SpecItem` models.
8. Introduce local storage repository for experiences and artifacts.
9. Update master resume and portfolio features to select/link stored experiences.

## Current Progress

- Added first-pass domain models under `lib/domain/models`.
- Added `ExperienceType` under `lib/domain/enums`.
- Added repository interfaces for experiences and spec items.
- Chat models live in `lib/domain/models/chat_models.dart` (legacy `lib/model.dart` barrel removed).
- Added `ExperienceSpecFormState.toExperiences()` and `toSpecItems()` as adapters without changing current UI behavior.
- Added `PromptBuilder` under `lib/data/services` and moved main prompt string composition out of `main.dart`.
- Added `GeminiService` under `lib/data/services` and moved direct Gemini stream calls out of `main.dart`.
- Added `AttachmentService` under `lib/data/services` and moved file picking, size validation, and MIME validation out of `main.dart`.
- Added `ExportRequest` and `ExportArtifactType` so export calls can carry artifact metadata while preserving the old export wrapper.
- Added JSON serialization to `Experience`, `DateRange`, and `SpecItem`.
- Added `JsonCareerRepository` under `lib/data/local` as a first local persistence implementation for experiences and spec items.
- Wired `ExperienceSpecForm` to save current structured inputs into `JsonCareerRepository` via a new "경험 카드로 저장" action.
- Loaded saved `Experience` records into app state, displayed them in `MasterResumeWorkspace`, and included them in master resume/portfolio prompt context.
- Added Q1-Q6 per-question Experience selection in `MasterResumeWorkspace`; selected IDs are passed into AI draft prompts and export metadata.
- Added `MasterEssay`/`EssayVersion` JSON persistence and wired "버전 저장" actions in the master resume workspace.
- Loaded saved essay version counts and displayed "저장된 버전 N개" per Q1-Q6/full-review tab.
- Added "버전 불러오기" actions that list saved `EssayVersion` records and restore the selected version into the current editor.
- Restored saved `sourceExperienceIds` into the per-question Experience selection state when loading a Q1-Q6 essay version.
- Extracted reusable chat display widgets and composer widgets into `lib/core/widgets`, reducing `main.dart` UI rendering detail.
- Added `ChatFlowController` under `lib/features/chat` to own user-message display text, prompt creation, and AI stream request setup.

## GeminiService Plan

Create a service boundary:

```dart
abstract class AiService {
  Future<String> generateText(AiRequest request);
}
```

`GeminiService` should own:

- API initialization
- Model selection
- Text + attachment request creation
- Error handling and user-readable failures

`main.dart` should not build raw Gemini requests directly.

## PromptBuilder Plan

Move mode-specific prompt composition into builders:

- `ExperiencePromptBuilder`
- `MasterResumePromptBuilder`
- `PortfolioPromptBuilder`

Builders should accept structured inputs such as `Experience`, `SpecItem`, `MasterEssay`, and attachment metadata.

## ExportService Plan

Keep `ExportService` as the central export path. Improve it later by:

- Accepting typed export requests
- Adding metadata such as document title and source artifact
- Supporting exported version tracking

## ExperienceSpecForm Plan

Short term:

- Keep the current form behavior.
- Add adapter methods that produce `Experience` and `SpecItem` lists.

Medium term:

- Rename or split into `ExperienceCardEditor`.
- Save cards locally.
- Allow edit/delete/versioning per experience.

## Master Resume Integration

`MasterResumeWorkspace` should receive available experiences and allow selecting relevant cards for each question. AI draft requests should include only selected experience facts plus target job.

## Portfolio Integration

Portfolio mode should operate on `PortfolioProject` cards derived from project-like experiences. AI can help convert an experience into portfolio copy, but the source experience remains linked.

## Local Storage Plan

Start with a repository interface:

```dart
abstract class ExperienceRepository {
  Future<List<Experience>> list();
  Future<void> save(Experience experience);
  Future<void> delete(String id);
}
```

Implementation options:

- Phase 1: JSON file or shared preferences for simple local persistence.
- Phase 2: Hive, Isar, or SQLite if querying/versioning grows.

## Test Strategy

- Unit test prompt builders to ensure no fake facts are inserted.
- Unit test model serialization.
- Unit test export formatting.
- Widget test key form flows.
- Add regression tests before major `main.dart` extraction.
