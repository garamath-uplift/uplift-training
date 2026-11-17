---
name: readme-healthcheck
description: Check the ai-training READMEs against the repo and SharePoint. Matches each module's local source file names to SharePoint files and fills in the root README's "Source files" table with their links, checks SCORM package naming and module READMEs, and lists open TODOs. Use when the user runs /readme-healthcheck or asks to check, refresh or fix the README, source links or package records.
---

# README healthcheck

Report on the health of the ai-training docs, then propose fixes. **Never write to any file until the
user approves the proposed changes.** That is Uplift's review rule for anything touching district files.

Run from the `ai-training` repo root. Read `README.md` and `CLAUDE.md` first.

## 1. Gather local state

For each folder in `modules/*/`:
- **Source files:** list the files in `modules/<module>/source/` and `modules/<module>/sources/`
  (either spelling). These are gitignored local working copies. Use only their **file names**. Don't
  open or read their contents.
- **Packages:** list every `*.zip` in `modules/<module>/`.
- **Module README:** check whether `modules/<module>/README.md` exists.

## 2. Find each source file in SharePoint

For each local source file name, call `mcp__claude_ai_Microsoft_365__sharepoint_search` with:
- `query`: the file name without its extension, for example `AI Literacy and Ethics - Foundations`
- `fileType`: the extension without the dot, for example `pptx`
- `limit`: 10, `offset`: 0

Keep only results whose file name **exactly** matches the local file name, ignoring case. Then:
- **One exact match:** use its `webUrl`.
- **Several exact matches:** don't guess. List each one's folder path, modified date and author, and
  ask the user which is the master copy.
- **No exact match:** report it as **not in SharePoint**. Remind the user that the file exists only
  on this computer and should be copied to the team's SharePoint library. The connector's upload tool
  is limited to 1 MB, so decks have to be uploaded by hand or through OneDrive sync.

Use only metadata from search results (name, path, webUrl, dates, author). **Don't call
`read_resource` on the files** unless the user explicitly asks for their content to be reviewed.

If the Microsoft 365 tools aren't available, skip this step, say the connector needs authorizing
through `/mcp`, and carry on with the local checks.

## 3. Check the root README's "Source files" table

The root `README.md` should have a `## Source files` section with this table, one row per source file:

```
| Module | Source file | Location |
|---|---|---|
| foundations | AI Literacy and Ethics - Foundations.pptx | [SharePoint](<webUrl>) |
```

Compare it with what you found:
- **Missing row:** propose adding it. Use `Not in SharePoint yet` as the location if there was no match.
- **Link differs from the current `webUrl`** (the file moved or was renamed): propose the new link.
- **Row for a source file that no longer exists locally:** flag it, but **don't** propose removing
  it. The local copy may simply have been cleaned up. Ask the user.

## 4. Check packages and module READMEs

- Each package must match `<module>-v<major>.<minor>-scorm.zip`. A zip that doesn't match is silently
  ignored by git, so flag it and suggest the correct name.
- Each module with a package needs a `modules/<module>/README.md` with a version history entry for
  every package version and a line saying where its source lives. Flag missing ones.
- Check that the module folder names are `kebab-case`.

## 5. Check the root README

- List every remaining `TODO`.
- Confirm the Uplift AI Guidebook link and the approved-tools table (Uplift Education vs. Uplift CMO)
  are still present. Report it if either is missing. **Never** reword the tools message.
- Confirm that the README still says **SCORM 2004 4th Edition** and **PowerSchool Professional Learning**.

## 6. Report, then fix on approval

Report in this order and keep it short:

1. **Summary:** ✅ healthy, or the number of issues found
2. **Source links:** a table of each file, its SharePoint match status and the proposed action
3. **Packages and module READMEs:** issues only
4. **Open TODOs**
5. **Proposed edits:** the exact changes to each file, shown as diffs

Then ask: "Apply these changes?" Make only the edits the user approves, then show `git diff --stat`.
Don't commit unless the user asks.
