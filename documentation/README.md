# Building Uplift training modules

These documents explain how to turn a PowerPoint, PDF or Word document into a self-paced, branded Uplift training module for **PowerSchool Professional Learning**. They are based on what we learned building *AI Literacy and Ethics: Foundations* (v1.0 to v3.3).

Foundations is the model these documents and the starter template come from. It wasn't built with them, though, and nothing here applies to the existing Foundations package (v3.3 and later), which is maintained separately.

You don't need to be a web developer. You'll build each module in an IDE (VS Code or any other editor) with an AI assistant. The assistant does the coding and runs the checking and packaging tools for you. These documents tell it, and you, how Uplift modules should look, read, behave and report to the LMS.

**What you need:** an IDE, Git and an AI assistant extension, all of which can be installed without admin rights, plus access to the `ai-training` repo. **First time? Start with [00 Getting started](00-getting-started.md)**, which walks you through setup step by step. Nothing else: the tools run on PowerShell, which is already part of Windows. Mac users install PowerShell 7 once, also without admin rights (see [tools/README.md](../tools/README.md)).

---

## Start here

| If you want to… | Read |
|---|---|
| Set up your computer and start your first module | [00 Getting started](00-getting-started.md) |
| Understand the whole process, start to finish | [01 Framework](01-framework.md) |
| Plan a new module (theme, look, goals, length) | [02 Design questionnaire](02-design-questionnaire.md) |
| Turn your PowerPoint, PDF or Word file into slides | [03 Source conversion](03-source-conversion.md) |
| Write or edit on-screen text | [04 Style guide](04-style-guide.md) |
| Choose colors, layouts and interactions | [05 UX/UI guide](05-ux-ui-guide.md) |
| Make sure every staff member can use the module | [06 Accessibility](06-accessibility.md) |
| Set up section checks, completion and scoring | [07 Assessment and SCORM](07-assessment-and-scorm.md) |
| Review a module before it goes to the LMS | [08 Review checklist](08-review-checklist.md) |
| Find a prompt to use with your AI assistant | [09 Prompt library](09-prompt-library.md) |

**Templates**

- [templates/module-brief.md](templates/module-brief.md): the plan for one module. The design questionnaire fills it in, and it then guides the whole build.
- [templates/module-readme.md](templates/module-readme.md): the README every module folder needs.
- [../templates/module-starter/](../templates/module-starter/): a working, unthemed module to copy as your starting point.

## The short version

1. **Make a branch** and ask your assistant to set up the module. It copies the starter for you.
2. **Remove student and staff information** from your source file before your AI assistant sees it.
3. **Answer the design questionnaire.** The assistant interviews you and writes the module brief.
4. **Approve the outline** the assistant proposes. After this point, *you* lead and the assistant follows.
5. **Build and revise** one section at a time.
6. **Review** with the checklist, **package** as SCORM 2004 4th Edition and **test**.
7. **Open a pull request**, update the module README, then upload to the LMS.

## What stays the same in every module, and what can change

| Same in every module (the **core**) | Your choice for each module (the **theme**) |
|---|---|
| Top bar, menu, Previous and Next, Resources and Settings | Theme or metaphor (Foundations uses space, but yours doesn't have to) |
| Locked Next until an activity is done | Colors (checked for contrast before use) |
| Section checks, completion and score reporting | Iconography and illustration style |
| WCAG 2.1 AA accessibility, reduced motion, keyboard and tap support | Amount of motion and whether sound effects are offered |
| Plain-language writing and Uplift terms | Activities you pick from the component catalog |
| Fictional names and data only. No real student or staff information | Section names, number of sections, length |

## Getting help

Email `ai@uplifteducation.org`. Say which step or document you're on, and don't include student or staff information.

## Who these docs are for

Anyone at Uplift who builds or reviews staff training: instructional designers, coaches, department leads who own content, and the reviewers who approve it. An AI assistant in your IDE reads these documents too. The repo's [AGENTS.md](../AGENTS.md) points it here.
