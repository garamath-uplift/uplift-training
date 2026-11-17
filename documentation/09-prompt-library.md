# 09 Prompt library

Prompts for working with your AI assistant at each phase of the [framework](01-framework.md). Every prompt is written in **CRAFT order: Context, Role, Action, Format, Tone**. Copy one, fill in the `[brackets]` and send it.

The assistant has read [AGENTS.md](../AGENTS.md), which tells it about these documents and how this library works. You don't need to paste the docs in.

---

## How the library changes as you go

The library works differently before and after the outline is approved, matching [who leads](01-framework.md#who-leads-the-conversation).

| | Phases 1–3: the assistant leads | Phases 4–7: you lead |
|---|---|---|
| Where prompts come from | Mostly the assistant. It **proposes** your next prompts. | Mostly you. Use the starters below or write your own. |
| What the assistant ends each turn with | 2–3 **proposed prompts** for this module | A short **what changed** list |
| Who decides what's next | The assistant suggests, you choose | You |

### How proposed prompts work

During intake, the design interview and the outline, the assistant ends each turn like this:

> **Suggested next prompts**
> 1. *Draft the Section 2 outline using the sort activity for the "approved vs. not approved" table.*
> 2. *Show me two theme palettes: one closer to Uplift navy, one warmer.*
> 3. *Which source slides did you suggest cutting, and why?*

Each suggestion is:

- **Specific to this module.** It names real sections, slides or decisions, not generic advice.
- **The next useful step**, usually in framework order, plus one "go deeper" option.
- **Short**, so you can send it as is or edit it.

You can reply with just the number ("2"), edit one, or ask something else.

After outline sign-off the assistant stops proposing unless you ask: "**Suggest next prompts.**"

### Keeping prompts that work

- The assistant logs useful prompts in the brief's **Prompt log** as it goes.
- At the end of a module, ask: "**Which prompts from the log should go into the prompt library?**" Add the good ones to this file in a pull request, using CRAFT order, with any module-specific details replaced by `[brackets]`.

---

## Phase 1: Intake

**Start a module**
```
Context: I'm starting a new Uplift training module from [source file name], which I've checked for student and staff information. It's for [audience].
Role: Act as the instructional designer for this module, following documentation/ in this repo.
Action: Read the source and AGENTS.md, then start Phase 1 of the framework. You lead until the outline is approved.
Format: Give me the source inventory table from 03-source-conversion.md, then your questions.
Tone: Plain language. I'm not a web developer.
```

**Inventory**
```
Context: [Source file] is in modules/[module-name]/.
Role: Act as an instructional designer converting live training to self-paced.
Action: Inventory every slide or page: what it teaches, and keep, rewrite, split, merge, turn into an activity, turn into a check question or cut. Flag presenter-only content, anything out of date, and anything that disagrees with [policy].
Format: The inventory table from 03-source-conversion.md, then a short list of flags.
Tone: Direct. Explain cuts in one line each.
```

**Policy check**
```
Context: This module must follow [policy name and version].
Role: Act as a policy reviewer.
Action: List every place the source states a rule, and whether it matches the policy. Quote the policy section for each mismatch.
Format: Table: source location, rule, matches?, policy reference.
Tone: Neutral and exact.
```

## Phase 2: Design interview

**Run the questionnaire**
```
Context: The inventory is done.
Role: Act as the designer interviewing me.
Action: Run 02-design-questionnaire.md one section at a time, with a suggested answer for each question. Write my answers into BRIEF.md.
Format: Up to 4 questions per turn, then suggested next prompts.
Tone: Friendly and quick.
```

**Propose a palette**
```
Context: The theme is [theme], it should feel [three words], and I want [colors to use or avoid].
Role: Act as a UI designer who knows WCAG 2.1 AA.
Action: Propose theme tokens following 05-ux-ui-guide.md "Choosing theme colors". Calculate every required contrast ratio, fix any failures, and offer a second option.
Format: Swatch table (token, hex, use), then a contrast table (pair, ratio, pass or fail).
Tone: Brief. Recommend one option.
```

**Icon, illustration and motion rules**
```
Context: Theme [theme], feel [three words], motion level [none, subtle or playful].
Role: Act as a visual designer.
Action: Write one rule each for icons, illustrations and motion, and list the themed art each slide type would need.
Format: Three short rules, then a table: slide type, art needed, reduced-motion version.
Tone: Concrete.
```

## Phase 3: Outline

**Draft the outline**
```
Context: BRIEF.md has the goals, theme and assessment choices.
Role: Act as the instructional designer.
Action: Propose a slide-by-slide outline using the default structure in 01-framework.md, unless the brief says otherwise.
Format: For each section: slides with slide type, component, gate and milestone, then check questions with the correct answer and pass mark.
Tone: Plain. Mark anything you're unsure about.
```

**Draft check questions**
```
Context: Section [n] teaches [topic]. The key message is [message].
Role: Act as an assessment writer.
Action: Write [n] multiple-choice questions that test applying the idea, following 07-assessment-and-scorm.md. Use fictional names only.
Format: Question, 3–4 options, correct answer, and why each wrong option is tempting.
Tone: Realistic school and office situations.
```

**Sign off** (handoff)
```
Outline approved. Record it in BRIEF.md with today's date. From now on I lead: follow my instructions, ask before changing anything outside what I ask for, and end each turn with a short "what changed" list.
```

## Phase 4: Build

**Set up the theme**
```
Context: The starter is copied to modules/[module-name]/sources/[source-name]/. The approved palette is in BRIEF.md.
Role: Act as the front-end developer.
Action: Set the theme tokens and the title, Resources links and section names. Don't add slide content yet.
Format: Edit index.html, then list what changed.
Tone: —
```

**Build a section**
```
Context: Section [n] of the approved outline in BRIEF.md.
Role: Act as the front-end developer.
Action: Build only these slides using the starter's components. Use the outline's text, or draft text that follows 04-style-guide.md and mark it "draft". Fictional data only.
Format: Edit index.html, then list the slides added and anything I should check in the browser.
Tone: —
```

**Change one slide**
```
Context: The "[slide title]" slide.
Role: Act as the front-end developer.
Action: [The change]. Don't change any other slide.
Format: Edit, then a one-line summary.
Tone: —
```

**Add a themed animation**
```
Context: The "[slide title]" slide, theme [theme].
Role: Act as a front-end developer who designs accessible motion.
Action: Add [animation] with a still version for reduced motion, Pause if it runs more than 5 seconds, and nothing the learner must wait for.
Format: Edit, then say how it behaves with reduced motion.
Tone: —
```

## Phase 5: Review

**Self-review**
```
Context: The module in modules/[module-name]/ is built.
Role: Act as a reviewer for content, accessibility and FERPA.
Action: Run every item in 08-review-checklist.md you can check from the files: contrast, alt text, heading order, leftover [[PLACEHOLDER text, real-looking names, links, DEV flag, style-guide words. Don't fix anything yet.
Format: The checklist with ✅, ❌ (with the line) or "needs a person".
Tone: Exact.
```

**Fix review findings**
```
Context: The review findings above.
Role: Act as the front-end developer.
Action: Fix items [numbers] only.
Format: Edit, then a list of what changed.
Tone: —
```

## Phase 6: Package and test

**Package**
```
Context: The module passed review. It's version [v1.0].
Role: Act as the SCORM packager.
Action: Run tools/module.ps1 package for this module, fix anything it reports, and run it again until it passes.
Format: In plain language: what was fixed, the zip path, and whether the LMS upload is Replace or New course, and why.
Tone: —
```

## Phase 7: Release

**Write the README and pull request**
```
Context: [module-name] v[version] is packaged and tested.
Role: Act as the release writer.
Action: Fill in modules/[module-name]/README.md from documentation/templates/module-readme.md, and draft the pull request description with the review checklist.
Format: Edit the README, then show the PR text.
Tone: Plain language for staff and reviewers.
```

**Promote prompts to the library**
```
Context: The prompt log in BRIEF.md.
Role: Act as the keeper of documentation/09-prompt-library.md.
Action: Pick the prompts worth reusing, generalize them with [brackets], and put them in CRAFT order.
Format: A proposed diff to 09-prompt-library.md.
Tone: —
```
