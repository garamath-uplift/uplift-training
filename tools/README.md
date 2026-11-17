# Module tools

Scripts that check, preview and package Uplift training modules built from [templates/module-starter](../templates/module-starter/).

**You usually don't run these yourself.** Your AI assistant runs them (it learns how from [AGENTS.md](../AGENTS.md)) and tells you what they found in plain language. They're here so the assistant can check things exactly instead of guessing, and so every module is packaged the same way.

## What each command does

| Command | What it does |
|---|---|
| `new <name>` | Starts a module: copies the starter to `modules/<name>/`, sets its title, ID and settings, and adds a README and a BRIEF.md (the plan, not committed) |
| `check <name>` | Looks for problems: leftover placeholders, Dev mode left on, missing alt text, files loaded from the internet, milestones and checks that don't match, wording ("Select", not "Click"), possible real IDs or emails, and color contrast |
| `contrast <name>` | Just the color contrast table (WCAG 2.1 AA) |
| `slides <name>` | Lists the slides with their line numbers, or shows one slide (`slides <name> 6`) or one section (`-Section s1`) |
| `preview <name>` | Builds the module with a **test LMS panel** and opens it in your browser, so you can watch completion, score and resume work without uploading anything |
| `package <name>` | Builds the SCORM 2004 4th Edition zip: checks first (strictly), puts the images and sounds inside the page, adds the tracking code, writes the manifest, verifies the zip, and says whether the LMS upload should **replace** the last version or be a **new course** |

`<name>` is the module's folder under `modules/`. Exit codes: 0 means OK, 1 means problems were found, 2 means the command couldn't run.

## Running them yourself

Nothing to install on Windows, and no admin rights needed.

- **Windows:** double-click `tools\module.cmd` for a menu, or type `tools\module.cmd check my-module` in any terminal.
- **Mac or Linux:** double-click `tools/module.command`, or type `tools/module.command check my-module`. This needs **PowerShell 7**, which you can install into your home folder without admin rights. If it's missing, the launcher prints the steps. You can also skip it: GitHub runs the same checks for you (below).
- **Any terminal with PowerShell:** `tools/module.ps1 <command> <name>`.

Works the same in any editor (VS Code, JetBrains, Cursor, or none).

## On GitHub

Every pull request that touches `modules/`, `templates/` or `tools/` runs `check` on Windows PowerShell 5.1 and PowerShell 7, then builds each module's package and attaches it to the run (kept for 14 days). Modules without a settings block, such as Foundations, are skipped.

## Files

| File | What it is |
|---|---|
| `module.ps1` | All the commands |
| `module.cmd` | Windows launcher |
| `module.command` | Mac and Linux launcher |
| `scorm/*.xsd` | The standard SCORM 2004 4th Edition schema files that go in every package |

The tracking code that goes into every package is [templates/core/scorm-runtime.js](../templates/core/scorm-runtime.js).
