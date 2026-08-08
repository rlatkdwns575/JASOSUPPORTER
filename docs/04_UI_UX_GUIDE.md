# 04. UI/UX Guide

## Design Direction

JasoSupporter should feel practical, calm, and trustworthy. Preserve the ProductSans font and blue/teal color direction.

## Color Direction

Use the shared app palette rather than Material default purple tones.

Current palette source:

- `lib/core/theme/app_colors.dart`

Preferred colors:

- Primary: deep blue/teal
- Surface: light slate/blue gray
- Borders: muted slate
- Error: standard red only for errors

## Language

Keep UI text in Korean by default.

Tone:

- Clear
- Practical
- Employment-oriented
- Not exaggerated

## Experience-Centered UX

The app should guide users from raw inputs to reusable cards:

1. Add an experience.
2. Structure it into STAR fields.
3. Tag competencies and evidence.
4. Reuse it in essays, portfolio, interviews, and applications.

## Form Behavior

- Optional sections should start collapsed or empty with an add button.
- Repeated items such as certificates, club activities, contests, internships, projects, and training should support multiple entries.
- Empty categories should not force users to type `없음`.

## AI Action UX

AI actions should make it clear what will happen:

- Organize into a table
- Build STAR structure
- Draft essay from selected experiences
- Convert to portfolio project
- Prepare interview answer

AI output should be easy to apply back to a structured artifact, not only copied from chat.

## Layout Guidance

- Keep split-pane behavior for productivity.
- Avoid overlay panels that block writing.
- Prefer side panels or resizable panels for tips and references.
- Keep chat visible as a support area, not the only workspace.

## Export UX

Exports should clearly indicate source:

- Experience summary
- Master essay version
- Portfolio project
- Interview answer
- Application record
