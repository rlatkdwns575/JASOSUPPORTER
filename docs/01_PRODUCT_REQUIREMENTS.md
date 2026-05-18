# 01. Product Requirements

## Product Goal

Help users build a reusable career content system from structured experiences.

## Primary Users

- Job seekers preparing Korean resumes, self-introduction essays, interviews, and portfolios
- Early-career users who need to organize scattered experiences
- Users applying to multiple companies and reusing the same experience with different emphasis

## Core User Jobs

1. Enter experiences and specs in a structured way.
2. Turn experiences into STAR-based records.
3. Use selected experiences to draft master essays.
4. Convert project-like experiences into portfolio cards.
5. Prepare interview answers grounded in real experiences.
6. Track company-specific applications and submitted content.
7. Export outputs as TXT, PDF, or simple DOCX.

## Existing Modes To Preserve

- `experienceSpec`: structure raw experiences/specs.
- `masterResume`: write and improve Q1-Q6 master essay answers.
- `portfolio`: build portfolio structure and copy.

## Future Feature Areas

### Experience Cards

Each experience should become a persistent card with STAR fields, tags, evidence links, and reusable metadata.

### Master Essays

Master essays should reference one or more experience cards. AI should recommend relevant experiences before drafting.

### Portfolio Projects

Portfolio project cards should be derived from project-like experiences and include role, stack, problem, action, result, and evidence.

### Interview Answers

Interview answers should be generated from selected experiences using STAR format, with concise and long-form variants.

### Application Records

Application records should track company, role, status, deadline, selected experiences, submitted essay versions, and notes.

## AI Behavior Requirements

- Use only user-provided facts.
- Ask when critical facts are missing.
- Mark missing metrics instead of inventing them.
- Keep Korean output by default.
- Preserve user's real context even when improving style.
