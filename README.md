# ai-training

This repo holds Uplift Education's AI training modules, built as **SCORM 2004 4th Edition** packages for our Learning Management System (LMS), **PowerSchool Professional Learning**.

> **Building a new module?** Start with [documentation/](documentation/README.md). It walks you from a PowerPoint, PDF or Word file to a finished, accessible, Uplift-branded module, with an AI assistant in your IDE doing the coding. New modules start from [templates/module-starter/](templates/module-starter/). AI assistants read [AGENTS.md](AGENTS.md).

---

## How AI training is delivered through the LMS

Each training module is a **SCORM package**: a `.zip` file with the course content (HTML, JavaScript, media) and an `imsmanifest.xml` file that tells the LMS how to launch and track it.

1. **Author:** a module is built in an authoring tool, usually from a PowerPoint deck. Source files stay on the team's shared drive.
2. **Package:** the module is published as a SCORM `.zip` and committed to this repo.
3. **Upload:** an LMS admin uploads the package to PowerSchool Professional Learning and assigns it to staff, by role, campus or department.
4. **Launch:** a learner opens the course in the LMS, which runs it in the browser.
5. **Track:** while it runs, the course reports progress back to the LMS through the SCORM runtime API: completion status, pass/fail, score, time spent and where to resume.
6. **Report:** admins and managers see completion and score data in LMS reports.

Because the LMS only sees what the package reports, **each module must report completion (and a score, if it has an assessment) the right way**, or learners won't get credit.

### SCORM version: 2004 4th Edition

**Publish every module as SCORM 2004 4th Edition.** Choose it in your authoring tool's publish settings. Don't use SCORM 1.2 or an earlier 2004 edition.

Things to know about this version:

- **Completion and pass/fail are tracked separately.** `cmi.completion_status` records whether the learner finished (`completed` / `incomplete`), and `cmi.success_status` records whether they passed (`passed` / `failed`). If a module has an assessment, set both.
- **Scores** go in `cmi.score.scaled` (from -1 to 1) and `cmi.score.raw`.
- **Resume data** (`cmi.suspend_data`) can hold up to 64,000 characters, which is plenty for bookmarking.
- **Sequencing rules** in the manifest can control the order of SCOs and lock content until earlier parts are done. Keep them simple unless the module really needs them.

---

## Repo structure

```
ai-training/
├── modules/
│   └── <module-name>/
│       ├── <module-name>-v1.0-scorm.zip   # finished package, exactly as uploaded to the LMS
│       ├── <module-name>-v1.1-scorm.zip
│       ├── sources/
│       │   └── <source-name>/             # hand-written HTML source, if the module has one
│       │       ├── index.html
│       │       └── assets/
│       └── README.md                      # summary, audience, version history, source location
├── documentation/                         # how to build a module: framework, style, UX/UI, accessibility, SCORM, prompts
├── templates/
│   └── module-starter/                    # unthemed, working module to copy for a new module
├── AGENTS.md                              # instructions for any AI assistant in the IDE
└── README.md
```

**Git holds finished SCORM packages, READMEs and hand-written HTML sources.** When a module is written directly in HTML (no authoring tool), its `index.html` and `assets/` folder live in git under `sources/`, so every change can be reviewed and the package can be rebuilt. Other source files (PowerPoints, Storyline `.story` and Captivate `.cptx` files, iSpring projects, raw media) stay on the team's shared drive. The [.gitignore](.gitignore) uses an allowlist: inside any folder, only `README.md`, `*-scorm.zip` and `sources/*/index.html` plus `sources/*/assets/` files can be committed. Anything else is ignored automatically, and so are build scratch folders like `dist/` and `build/`.

Before committing an HTML source, check that it and its assets hold no real student or staff names, photos or data.

Because decks and authoring-tool files aren't in git, **each module README must say where its source files live** so someone else can make the next update.

## Source files

Where each module's editable source lives, in SharePoint or in this repo. Run `/readme-healthcheck` in Claude Code to fill in and refresh this table.

| Module | Source file | Location |
|---|---|---|
| foundations | 00 - Foundations AI Literacy and Ethics.pptx | [SharePoint](https://uplifteducation.sharepoint.com/:p:/s/FIPSE-AI-Grant/IQD-pyWYpZUDRIl-HVZrb1jTAZWHN4Ws_WcUanRspfW2Uh4) |
| foundations | 00 - Foundations AI Literacy and Ethics/ (module HTML source: index.html + assets) | This repo: [modules/foundations/sources/](modules/foundations/sources/) |

### Naming

- Module folders: `kebab-case`, for example `ai-foundations`, `prompting-for-educators` or `ai-and-student-data`
- Packages: `<module-name>-v<major>.<minor>-scorm.zip`, for example `ai-foundations-v1.2-scorm.zip`

---

## Workflow for adding or updating a module

1. **Branch:** create a branch, for example `module/ai-foundations-v1.2`.
2. **Edit the source:** the HTML source in `sources/` if the module has one, otherwise the files on the shared drive.
3. **Publish** a SCORM 2004 4th Edition package, named `<module-name>-v<major>.<minor>-scorm.zip`.
4. **Test** before it goes to the LMS (see below).
5. **Commit the package** to `modules/<module-name>/`. Keep earlier versions so there's a record of what was live and when.
6. **Update the module README** with what changed, the new version number and the source location.
7. **Open a pull request** for review: content, accessibility and data privacy.
8. **Upload** the approved package to the LMS.
   - When you update a live course, check whether the LMS will **replace** the package (keeping learner progress) or create a **new course**, which resets completions.

### Testing checklist

- [ ] Launches in a SCORM test environment (for example [SCORM Cloud](https://cloud.scorm.com)) or the LMS sandbox
- [ ] Reports completion when the learner finishes
- [ ] Reports score and pass/fail correctly, if there is an assessment
- [ ] Resumes where the learner left off after they close and reopen it
- [ ] Works in Chrome, Edge and Safari, and on a tablet or phone
- [ ] Meets accessibility standards: captions, alt text, keyboard navigation and color contrast (WCAG 2.1 AA)

---

## Content guidance for AI training

Modules should help staff use AI tools **effectively, safely and in line with Uplift policy**. Topics to cover across the curriculum:

- **AI basics:** what generative AI is, what it can and can't do, and how it makes mistakes, such as hallucinations and bias
- **Approved tools:** which AI tools are approved for staff and students, and how to get access
- **Student data and privacy:** never enter student PII or education records into AI tools that aren't approved for it (FERPA)
- **Responsible and ethical use:** academic integrity, transparency, human review of AI output, and avoiding bias
- **Practical use in the classroom and the office:** lesson planning, feedback, communication and admin work
- **Policy:** how the Uplift Education User Policy and Code of Conduct apply to AI use

### Uplift AI policy

All content must follow the **[Uplift AI Guidebook (June 2026, v1)](https://uplifteducation.interactgo.com/Utilities/Uploads/Handler/Uploader.ashx?area=composer&filename=Uplift_AI_Guidebook_June2026_v1.pdf&fileguid=56458e7a-9a05-479f-b473-3d6ff293f11b)**. When the guidebook is updated, check the modules against the new version.

### Approved AI tools

Training should be clear about which tool to use for which kind of work:

| Tool | Internal name | FERPA-compliant? | Use for |
|---|---|---|---|
| **Microsoft Copilot** (district) | Uplift Education | ✅ Yes | Any approved work, including work with student data |
| **Claude** (district) | Uplift Education | ✅ Yes | Any approved work, including work with student data |
| **Claude** (non-profit) | Uplift CMO | ❌ No | Work that has **no** student PII or education records |

> **Key message for learners:** student PII and education records may only go into the FERPA-compliant **Uplift Education** tools. Never put them into **Uplift CMO** or any unapproved AI tool.

---

## Data privacy (FERPA)

- **Never commit learner data.** LMS completion reports, gradebook exports and SCORM tracking data can contain staff or student PII. The [.gitignore](.gitignore) blocks common report formats (`*.csv`, `*.xlsx`), but you are still responsible for checking what you commit.
- **Don't use real student or staff information** in examples, scenarios or screenshots. Use made-up names and data.
- **Use the right workspace when you build modules with AI.** Drafting content with no PII can happen in either Claude workspace. Anything involving real learner data belongs only in the **Uplift Education** (FERPA-compliant) tools, never **Uplift CMO**.
- **Don't send learner data to third-party services** (including external SCORM testing tools) without approval.
- **Never commit credentials** for the LMS or SCORM Cloud. Use a local `.env` file, which is ignored.

---

## Accessibility

All modules must be usable by every staff member:

- Captions or transcripts for every video and audio clip
- Alt text for meaningful images
- Full keyboard navigation and screen reader support
- Text and background colors that meet WCAG AA contrast
- Assessments that don't depend only on color or timing. Use drag-and-drop sparingly, and give it a keyboard and tap alternative
