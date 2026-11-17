# 02 Design questionnaire

The AI assistant uses this questionnaire to interview you at the start of a module (Phase 2 of the [framework](01-framework.md)). Your answers go into the [module brief](templates/module-brief.md), which guides every later decision.

**For the assistant:** ask one section at a time, with up to 4 questions per turn. Offer a suggested answer for each question, based on the source inventory and these defaults, so the designer can just confirm. Write the answers into the brief as you go. After section D, propose the palette (see [Choosing theme colors](05-ux-ui-guide.md#choosing-theme-colors)). End each turn with 2–3 suggested next prompts.

**For the designer:** "I don't know" and "use the default" are fine answers. Everything can be changed later.

---

## A. The module

| # | Question | Default |
|---|---|---|
| A1 | What's the module called? Give a working title and a `kebab-case` folder name. | From the source title |
| A2 | Who owns the content, and who approves it before release? | |
| A3 | Who must take it? (All staff, teachers, campus staff, central office, a department) | All staff |
| A4 | How long should it take? | 20–25 minutes |
| A5 | When does it need to be in the LMS? | |
| A6 | Is it brand new, or a new version of an existing course? (This decides **replace** or **new course** in the LMS.) | New |

## B. Source material

| # | Question | Default |
|---|---|---|
| B1 | What's the source? (PowerPoint, PDF, Word, more than one.) Where does the master copy live? | |
| B2 | Has it been checked for real student or staff information? (It must be clean before the assistant reads it.) | **Must be yes** |
| B3 | What policy or guidance does it follow? (For example, the Uplift AI Guidebook, June 2026, v1.) | |
| B4 | Is anything in the source out of date, presenter-only or meant for a live session? | The assistant flags it from the inventory |

## C. Goals

| # | Question | Default |
|---|---|---|
| C1 | After the module, what should staff be able to **do**? List 3–4 goals that start with a verb (Explain, Choose, Write, Protect…). | Drafted from the source |
| C2 | What's the single most important message? The one thing learners must not miss. | |
| C3 | What do staff get wrong today, or worry about, on this topic? | |
| C4 | Why does this matter for Uplift scholars and staff? | |

## D. Theme, look and feel

| # | Question | Default |
|---|---|---|
| D1 | Do you want a theme or metaphor (for example a journey, a toolkit, a field guide or a kitchen) or a clean, unthemed look? Foundations uses space, but **don't reuse it** unless the module belongs to that series. | Clean Uplift look |
| D2 | Name three words for how it should feel (for example calm, confident and practical, or bold, playful and curious). | Clear, warm, practical |
| D3 | Any colors you want or want to avoid? Name them or give hex codes. Light or dark backgrounds? | Uplift default palette, light content area |
| D4 | Illustration style: none, simple line drawings, flat shapes or diagrams? (Never photos of real students.) | Simple line drawings |
| D5 | Icon style: outline or filled? Rounded or sharp? One color or two? | Outline, rounded, 2px line, one color |
| D6 | How much motion: none, subtle (fades and small movements) or playful (characters, journeys)? Reduced motion is always respected. | Subtle |
| D7 | Should learners be offered sound effects (off by default, on-screen feedback always shown)? | Yes, off by default |

After D, the assistant proposes **theme colors** with a contrast table, an **icon and illustration rule** in one or two sentences, and a **motion rule**, all for your approval.

## E. Tone and words

| # | Question | Default |
|---|---|---|
| E1 | Where on this scale: friendly and casual, warm and professional, or formal? | Warm and professional |
| E2 | Any words to use or avoid? For example, Uplift says **scholars**, and approved tool names follow policy. | See the [style guide](04-style-guide.md) |
| E3 | Do the examples need to differ by role (Teacher, Campus staff, Central office)? | Yes, where tasks differ |

## F. Interactions

| # | Question | Default |
|---|---|---|
| F1 | Which activities fit the content? Pick from the [component catalog](05-ux-ui-guide.md#component-catalog): fold boxes, sort activity, role picker, select-the-parts, scenario questions, demos. | The assistant suggests 1–2 per section |
| F2 | Is there a process or tool learners should *see working* (an animated demo)? | No |
| F3 | Should learners have to finish each activity before Next unlocks? | Yes |

## G. Checks and completion

| # | Question | Default |
|---|---|---|
| G1 | Short checks after each section, one final check, or no scored checks? | A check after each teaching section |
| G2 | How many questions per check, and how many correct to pass? | 2–3 questions, about two thirds to pass |
| G3 | What counts as complete? | Every section reached and every check passed |
| G4 | Is a practice section needed (scenarios, not scored)? | Yes, role-based |

## H. Resources and support

| # | Question | Default |
|---|---|---|
| H1 | Which links go in the **Resources** menu? (Policy pages, guides, a contact email.) | |
| H2 | Who should learners contact with questions? | |

---

## Accessibility is not a question

Every module meets WCAG 2.1 AA, whatever its theme. That includes contrast, keyboard and tap support, alt text, captions or transcripts, reduced motion and sound that's never the only signal. The questionnaire doesn't ask whether to include these. See [06 Accessibility](06-accessibility.md).
