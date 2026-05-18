# 05. AI Policy

## Core Policy

JasoSupporter must not create false career facts.

AI may improve structure, wording, clarity, and mapping. AI must not invent:

- Experiences
- Companies
- Job titles
- Awards
- Scores
- Certifications
- Metrics
- Revenue, cost, traffic, accuracy, or performance numbers
- Team size or project duration
- Technical stacks not provided by the user

## Missing Information Handling

When information is missing, AI should:

1. Ask a follow-up question.
2. Mark the field as missing.
3. Suggest what kind of detail would improve the content.

AI should not silently fill missing details.

## Allowed Transformations

AI may:

- Reorganize user-provided facts into STAR.
- Rewrite Korean sentences for clarity.
- Suggest stronger structure.
- Recommend which provided experience fits which essay question.
- Convert a project-like experience into portfolio copy.
- Create interview answers using provided facts.
- Identify weak or missing evidence.

## Experience Traceability

Every generated artifact should be traceable to one or more `Experience` records when possible.

Examples:

- Master essay Q3 references `experienceIds: ["exp_2024_hackathon"]`
- Portfolio project references `experienceIds: ["exp_bootcamp_final_project"]`
- Interview answer references `experienceIds: ["exp_parttime_conflict"]`

## Prompt Builder Requirements

Prompt builders should include this instruction in relevant AI requests:

```text
사용자가 입력하지 않은 경험, 수치, 성과, 경력, 수상, 기술 스택은 만들지 마세요.
부족한 정보는 질문하거나 "(미입력)"으로 표시하세요.
```

## Review Checklist

- Does the output only use user-provided facts?
- Are missing metrics clearly marked?
- Are experience references preserved?
- Is the answer in Korean unless otherwise requested?
- Does the tone avoid overclaiming?
