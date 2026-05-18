# 02. Data Model

## Model Direction

Domain models should become the source of truth. UI forms and AI prompts should read from and write to these models instead of relying only on concatenated prompt strings.

## Core Models

### Experience

Required fields:

- `id`
- `title`
- `type`
- `period`
- `organization`
- `role`
- `situation`
- `task`
- `action`
- `result`
- `learned`
- `techStacks`
- `competencyTags`
- `evidenceLinks`
- `createdAt`
- `updatedAt`

Suggested Dart shape:

```dart
class Experience {
  final String id;
  final String title;
  final ExperienceType type;
  final DateRange? period;
  final String organization;
  final String role;
  final String situation;
  final String task;
  final String action;
  final String result;
  final String learned;
  final List<String> techStacks;
  final List<String> competencyTags;
  final List<String> evidenceLinks;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### SpecItem

Stores non-experience specs such as certificates, language scores, GPA, school, and major.

### MasterEssay

Represents one essay question workspace. It should reference selected `Experience` IDs.

Key fields:

- `id`
- `questionId`
- `questionText`
- `targetJob`
- `linkedExperienceIds`
- `currentVersionId`
- `createdAt`
- `updatedAt`

### EssayVersion

Stores drafts and revisions for a `MasterEssay`.

### PortfolioProject

Derived from one or more project-like experiences.

Key fields:

- `id`
- `title`
- `linkedExperienceIds`
- `role`
- `problem`
- `solution`
- `techStacks`
- `result`
- `evidenceLinks`
- `portfolioCopy`

### ApplicationRecord

Tracks company-specific applications.

Key fields:

- `id`
- `companyName`
- `position`
- `status`
- `deadline`
- `linkedExperienceIds`
- `submittedEssayVersionIds`
- `notes`
- `createdAt`
- `updatedAt`

### ChatMessage / ChatRoom

Existing chat types should move into `domain/models` and stay reusable across modes.

## Relationship Summary

- `Experience` is the base object.
- `MasterEssay`, `PortfolioProject`, `InterviewAnswer`, and `ApplicationRecord` reference experiences by ID.
- AI output should be saved as versions or derived artifacts, not only transient chat text.
