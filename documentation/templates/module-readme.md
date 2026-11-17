# [Module title]

> Template for `modules/<module-name>/README.md`. Replace everything in [brackets] and delete this note. See `modules/foundations/README.md` for a finished example.

[One or two sentences: what the module covers and who it's for.]

| | |
|---|---|
| **Current version** | v[x.y]: [`<module-name>-v[x.y]-scorm.zip`](<module-name>-v[x.y]-scorm.zip) |
| **Audience** | [All staff / role groups] |
| **Length** | About [n] minutes, self-paced. Learners can stop and resume. |
| **Format** | SCORM 2004 4th Edition, one SCO, runs fully offline. Built from the Uplift module starter. |
| **Theme** | [theme, or "clean Uplift look"] |
| **Policy basis** | [policy name, version, link] |

## What learners do

[Slide count, sections in order with one line each, the activities that lock Next, the checks and pass marks.]

1. **[Section 1]:** [ … ]. Ends with a [n]-question check ([n] of [n] to pass).
2. …

All names and scenarios are fictional.

## How completion and scoring work

| LMS field | What sets it |
|---|---|
| `cmi.completion_status` | **completed** once [ … ] |
| `cmi.success_status` | **passed** once [ … ]. Never set to failed. |
| `cmi.score.raw` / `cmi.score.scaled` | [ … ] out of [n] / the same from 0 to 1 |
| `cmi.progress_measure` | Share of milestones reached: [list] |
| `cmi.suspend_data` | [ … ] |

## Source files

| File | What it is | Where it lives |
|---|---|---|
| [source deck / PDF / Word file] | Original source | [SharePoint link] |
| `[source-name]/` (`index.html` + `assets/`) | **The module itself.** Edit this to make the next version. | This repo: [sources/[source-name]/](sources/) |

## How to rebuild the package

1. Edit `sources/[source-name]/index.html`. Use `var DEV = true;` to test, and set it back to `false` before packaging.
2. Bump `version` in the module settings block at the top of `index.html`. Keep the `identifier` (`uplift-[module-name]`) the same in every version.
3. Run `tools/module.ps1 package [module-name]`, or ask your AI assistant to. See [documentation/07](../../documentation/07-assessment-and-scorm.md#packaging).
4. Test in SCORM Cloud or the LMS sandbox, then commit the zip next to earlier versions.

## Version history

| Version | Date | Changes | LMS upload |
|---|---|---|---|
| v1.0 | [date] | First release. [Built from …] | **New course** (first upload) |
