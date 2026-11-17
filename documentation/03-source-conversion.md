# 03 Source conversion: PowerPoint, PDF or Word to module

Most modules start from something that already exists: a live-session deck, a policy PDF or a Word handout. This guide covers how to turn it into a self-paced module without losing what matters.

## Step 1: Make it safe first

Before the AI assistant reads the source:

- [ ] Remove or replace real **student** names, IDs, photos, grades, records and anything from a student information system
- [ ] Remove or replace real **staff** names, photos and emails, except public contacts the module is meant to share (for example `ai@uplifteducation.org`)
- [ ] Remove screenshots that show real records, inboxes or rosters
- [ ] Check the speaker notes, comments, hidden slides and document properties too

If the source can't be cleaned (for example, its value *is* the real data), stop and ask your supervisor. Real student data must never go into a module.

## Step 2: Take inventory

Ask the assistant for an inventory table (prompt: [Inventory](09-prompt-library.md#phase-1-intake)):

| Source slide or page | What it teaches | Suggestion | Notes |
|---|---|---|---|
| Slide 4: "What is AI?" | Definition, examples | Keep, then split into 2 slides | Examples are good, add one for central office |
| Slide 9: "Turn and talk" | Discussion | Turn into an activity | Make it a sort activity or reflection |
| Slide 12: live demo | Copilot walkthrough | Turn into a demo | Animated demo with a text version |

Suggestions are one of **Keep**, **Rewrite**, **Split**, **Merge**, **Turn into an activity**, **Turn into a check question** or **Cut**.

## Step 3: Replace what only works live

Live sessions depend on a presenter. A self-paced module has to do that work on screen.

| In the live session | In the module |
|---|---|
| Presenter explains a slide | Short on-screen text plus fold boxes for detail (speaker notes are often the best source) |
| Live demo | Animated demo with Pause and Replay, and a text version for screen readers. Or a worked example. |
| Turn and talk, discussion | Reflection prompt (nothing typed is saved) or a scenario question |
| Show of hands, poll | Sort activity or "which of these…" question with instant feedback |
| Q&A | A Resources link and a contact email |
| Handouts | Links in the Resources menu (only to pages staff can reach) |
| Photos of students or staff | Illustrations or icons. Never photos of real students. |

## Step 4: Structure into sections

1. Group the kept content into **3–5 sections** (1–2 for a micro-module). Each section answers one question a learner would ask, for example "What is it?", "How do I stay safe?" or "How do I use it well?".
2. Put the **most important message** where no one can miss it. Often it belongs in its own section, and in a check question.
3. Turn the main ideas from each section into **check questions**. Test whether learners can apply an idea, not just recall a fact.
4. Add **practice** at the end if the skills differ by role.

## Step 5: Map content to slide types

Use the slide types and components in the [UX/UI guide](05-ux-ui-guide.md#component-catalog) and the [starter README](../templates/module-starter/README.md). Rules of thumb:

- **One idea per slide.** If a source slide has three ideas, make three slides or three fold boxes.
- **Bulleted lists of 4 or more** usually become a card grid or fold boxes.
- **Comparisons** (do and don't, weak and strong, approved and not approved) become side-by-side cards.
- **Steps or processes** become a numbered list or a demo.
- **Tables of rules** become a sort activity or scenario questions, plus a reference link.

## Step 6: Check facts and policy

- [ ] Every rule matches the current policy (for example the Uplift AI Guidebook). Where the source and the policy disagree, the policy wins. Flag it to the content owner.
- [ ] Tool names, approved-tool lists and links are current
- [ ] Every statistic says where it's from and when (for example "October 2026 staff survey, 160 respondents")
- [ ] Out-of-date content is cut, not softened

## Format notes

| Source | Tips |
|---|---|
| **PowerPoint** (`.pptx`) | The speaker notes often hold the real explanation. Check them and any hidden slides. Slide titles make good first drafts of headings. |
| **PDF** | Text order can be scrambled in multi-column layouts, so check the assistant's reading against the page. Scanned PDFs need OCR first. |
| **Word** (`.docx`) | Headings usually map to sections and slides. Tables often map to card grids or sort activities. |

Source files never go into git. Record where the master copy lives in the module README's **Source files** table.
