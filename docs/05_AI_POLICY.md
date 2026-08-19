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

## Two-Layer Model (Master Essay)

Generated master-essay content has two layers. AI must keep them separate.

### Fact layer (locked to Experience)

Only use facts present in the user's Experience records:

- Situation, task, action, result
- Metrics, numbers, percentages, counts, durations
- Organization, role, period
- Tech stacks, tools, certifications explicitly listed

Do not invent or infer new facts in this layer.

### Meaning layer (AI may expand)

On top of provided facts, AI should expand (without inventing new facts):

- Which strengths the experience reveals
- Insights and lessons grounded in the provided `learned` / competency tags
- A deductive opening (core message first, then evidence)
- Question-fit framing and differentiation vs generic applicants
- Clearer structure and wording

Do not produce "summary-only" output that merely paraphrases STAR fields. The essay should interpret and position the facts for the question.

## Allowed Transformations

AI may:

- Reorganize user-provided facts into STAR.
- Rewrite Korean sentences for clarity.
- Suggest stronger structure and deductive (two-gak) openings.
- Surface strengths, insights, and differentiation angles grounded in provided facts.
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
- Does the essay expand meaning (strengths, insights, deductive opening) rather than only summarizing STAR?
