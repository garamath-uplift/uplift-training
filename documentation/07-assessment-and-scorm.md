# 07 Assessment and SCORM

How modules check learning, decide completion and report to **PowerSchool Professional Learning**. The LMS only knows what the module reports, so getting this right is how staff get credit.

## Rules that never change

- Every module is **SCORM 2004 4th Edition**, one SCO. Never SCORM 1.2 or an earlier 2004 edition.
- Set both **`cmi.completion_status`** and **`cmi.success_status`**. If there's an assessment, set **`cmi.score.scaled`** (0 to 1) and **`cmi.score.raw`** too.
- Keep manifest sequencing simple. Gating happens inside the module, not in the manifest.
- Package name: `<module-name>-v<major>.<minor>-scorm.zip`. Keep the same `identifier` in every version.

## Section checks (default)

| Setting | Default |
|---|---|
| Where | At the end of each teaching section, after a short check-intro slide |
| Questions | 2–3 multiple-choice questions, one per slide |
| Pass mark | About two thirds (2 of 3, 1 of 2), set on each question with `data-pass` |
| Feedback | **Check my answer** marks the correct answer, and the learner's choice if it was wrong |
| Not passed | **Try again** clears that check and goes back to its first question |
| Retries | Unlimited. Next stays locked until the check is passed. |
| Failed | The module never sets **failed**. Learners retry until they pass. |

### Writing good check questions

- Test whether learners can **apply** the idea to a realistic situation, not recall a word from a slide.
- Every question must be answerable from the module's content.
- Make wrong options plausible: common mistakes, not jokes.
- Use 3–4 options. Avoid "all of the above" and "none of the above" unless "none" is the lesson (for example "Which task is OK on a personal account? None.").
- Use fictional names and data only.
- The most important message (C2 in the brief) should appear in at least one check question.

## Milestones and completion

Each module has **milestones**: one per section, plus one per check. They're `data-jalon` markers that the module reaches from its script, never by scrolling.

| A section counts as reached when… | A check counts as passed when… |
|---|---|
| Its last slide is shown, or, for a section with a check, the check is passed and the learner moves on | The learner reaches its pass mark |

Milestone IDs double as `data-section` values, for example `welcome`, `s1`, `check-s1`, `s2`, `check-s2`, `practice`, `wrapup`. **Never rename a milestone ID in a later version.** Renaming one resets learners' progress.

## What the module reports

| LMS field | Default behavior |
|---|---|
| `cmi.completion_status` | **completed** once every milestone is reached (every section and every check) |
| `cmi.success_status` | **passed** once every check is passed. The script sets it. |
| `cmi.score.raw` / `cmi.score.scaled` | Correct answers on each check's passing attempt, out of the total number of check questions / the same from 0 to 1. For information only. |
| `cmi.progress_measure` | Share of milestones reached. Matches the top-bar %. |
| `cmi.suspend_data` | Milestones reached and checks passed. A returning learner resumes at the first section not reached or the first check not passed. |
| `cmi.session_time`, `cmi.exit` | Time spent, and "suspend" when the window closes, so progress carries over |
| `cmi.interactions` | **Off by default.** When a module's settings say `"interactions": true`, each answered check question is recorded: question ID, the learner's answer, the correct answer, right or wrong, and the time. Retries are recorded too. Turn it on only if someone will use question-level reports in the LMS. |

The tracking code that reports these is [templates/core/scorm-runtime.js](../templates/core/scorm-runtime.js). It's readable and kept in the repo, so reviewers can see exactly what's sent to the LMS. In the LMS's browse or review mode it writes nothing.

**Options** (record the choice in the brief):

- **No scored checks:** completion only. Leave `success_status` unset, or set it to passed when complete, and don't report a score.
- **One final check** instead of section checks: one milestone for the check, and the same pass and retry rules.

## Packaging

Ask your AI assistant to **package the module**. It runs `tools/module.ps1 package <module>`, which needs nothing installed and no admin rights (see [tools/README.md](../tools/README.md)). The script:

1. Runs every check in strict mode, and stops if `DEV` is on, placeholders are left, or anything fails
2. Builds one offline `index.html`: assets embedded, tracking code added
3. Writes `imsmanifest.xml` correctly: SCORM 2004 4th Edition, completion threshold `1.0`, completion and success set by the module, no mastery score. Nothing needs editing by hand.
4. Adds the standard SCORM schema files and zips it all as `<module-name>-v<version>-scorm.zip`
5. Reopens the zip to verify it
6. Compares it with the previous version and tells you **Replace** or **New course**

The module's title, `identifier` and version come from the settings block at the top of its `index.html`. Keep the `identifier` the same in every version.

The `scorm` MCP tools aren't needed. If you have them, `scorm_validate` is a useful extra check on the finished zip. Foundations is packaged its own way, which its README describes. Nothing in this guide applies to it.

## Testing

**First, preview it.** Ask the assistant to preview the module (`tools/module.ps1 preview <module>`). It opens in your browser with a **Test LMS** panel showing completion, success, score, progress and milestones as you go. Close and reopen the tab to test resume, and use **Reset test learner** to start over. The panel is only in previews, never in packages.

**Then, before upload,** in SCORM Cloud or the LMS sandbox, with **fictional test accounts only**:

- [ ] Launches
- [ ] Reports **completed** only after every section and check
- [ ] Reports **passed** and the right score
- [ ] **Resumes** where the learner left off after closing and reopening
- [ ] Works in Chrome, Edge, Safari, and on a phone or tablet

Don't upload packages that hold learner data to outside testing services, and never commit LMS exports or completion reports.

## Updating a live module: replace or new course?

| Change | LMS upload |
|---|---|
| Wording, design, new slides, same milestone IDs | **Replace** (keeps learner progress and completions) |
| New check questions, same milestone IDs | **Replace**. Learners who passed stay passed. |
| Milestone IDs renamed or removed, or the `identifier` changed | **New course** (resets completions). Avoid this unless required. |

Always say which one in the module README's version history and in the pull request.
