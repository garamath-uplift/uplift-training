# 00 Getting started: your first time

This page gets you from nothing to your first conversation with the AI assistant. You only do it once. It takes about 30 minutes, plus any wait for GitHub access.

You don't need to know how to code or use a terminal. Everything here uses buttons and menus. After setup, the AI assistant does the technical work: copying files, running checks, packaging and saving your work.

**If you get stuck at any step,** email `ai@uplifteducation.org` with the step number and a screenshot. Make sure the screenshot shows no student or staff information.

---

## What you'll set up

| | What it is | Why you need it |
|---|---|---|
| **GitHub account** | The website where the training modules are stored | So you can get the files and share your work for review |
| **VS Code** | A free editor where you'll work on the module | It's where you talk to the AI assistant and see the files |
| **Git** | The program that keeps track of every change | VS Code uses it in the background. You won't use it directly. |
| **AI assistant** | Claude, signed in with your Uplift account | It builds the module with you |

---

## Step 1: Get access to the repo

The modules live in a GitHub *repository* (repo for short) called `ai-training`, in Uplift's **Uplift-Education** organization.

1. If you don't have a GitHub account, create one at [github.com](https://github.com) with your **Uplift email address**.
2. Email `ai@uplifteducation.org` and ask to be added to the `ai-training` repo. Include your GitHub username.
3. Wait for the invitation email from GitHub, then select **Accept invitation**.

**Done when:** you can open `https://github.com/Uplift-Education/ai-training` while signed in and see the files.

## Step 2: Install VS Code

1. Go to [code.visualstudio.com/download](https://code.visualstudio.com/download).
2. Under Windows, choose **User Installer** (x64). The User Installer puts VS Code in your own folder, so it doesn't need an administrator password.
3. Run the downloaded file and accept the default choices.

On a Mac, download the Mac version, open it, and drag **Visual Studio Code** into your **Applications** folder (or your Downloads folder if Applications asks for a password).

**If any installer asks for an administrator password, stop.** Check whether the program is in your computer's Software Center or Company Portal, or ask IT for help. Don't use anyone else's password.

## Step 3: Install Git

**Windows**
1. Go to [git-scm.com/downloads/win](https://git-scm.com/downloads/win) and download the 64-bit installer.
2. Run it. If it asks whether to install for all users or only for you, choose **only for me**. Accept the other default choices.

**Mac:** Git is usually already there. In Step 5, if VS Code says Git is missing, select the button it shows to install it.

**Done when:** you've finished the installer. Restart VS Code if it was open.

## Step 4: Add the AI assistant

Use **Claude, signed in with your Uplift Education account**. It's one of the district-approved tools. Never use a personal or free AI account for Uplift work.

1. In VS Code, select the **Extensions** icon on the left (four small squares).
2. Search for **Claude Code** and select **Install** on the extension published by Anthropic.
3. Open it from the Claude icon on the left and select **Sign in**. Choose your **Uplift Education** Claude account in the browser window that opens.

**Done when:** the Claude panel is open and you can type a message.

## Step 5: Get a copy of the repo

This copies the training files from GitHub onto your computer. It's called *cloning*.

1. In VS Code, press **Ctrl+Shift+P** (on a Mac, **Cmd+Shift+P**), type **Git: Clone** and press Enter.
2. Choose **Clone from GitHub**. Select **Allow** and sign in to GitHub in the browser window that opens.
3. Choose **Uplift-Education/ai-training** from the list.
4. Pick a folder to keep it in, for example your **Documents** folder.
5. When VS Code asks, select **Open**. If it asks whether you trust the authors, select **Yes**.

**Done when:** you can see `README.md`, `documentation` and `modules` in the file list on the left.

## Step 6: Start your module

1. Open the Claude panel.
2. Copy this prompt, fill in the `[brackets]`, and send it:

```
Context: I'm new to this repo and want to build a new Uplift training module called [short name, for example "ai-and-student-data"]. It's for [audience, for example "campus teachers"]. My source file is [file name], and I've removed all student and staff information from it.
Role: Act as the instructional designer for this module, following AGENTS.md and documentation/ in this repo.
Action: Make a branch for the module, set it up with the module tools, then start Phase 1 of the framework. You lead until I say the outline is approved.
Format: Tell me what you did in a short list, then tell me where to put my source file.
Tone: Plain language. I'm not a web developer.
```

3. The assistant creates a *branch* (your own working copy, so nothing you do affects anyone else), sets up the module folder and asks where your source file is.

**Done when:** the assistant has made the branch and the module folder, and it's asking you questions. From here, follow [01 Framework](01-framework.md).

---

## Before you share a source file

Your source PowerPoint, PDF or Word file must contain **no real student or staff information**: no names, ID numbers, photos, emails or records. Replace them with made-up ones *before* you give the file to the assistant. See [Phase 1](01-framework.md#phase-1-intake-the-assistant-leads). If you're not sure, ask your supervisor or `ai@uplifteducation.org` first.

## Words you'll see

| Word | What it means |
|---|---|
| **Repo** | The shared folder of training files on GitHub |
| **Clone** | Copy the repo onto your computer |
| **Branch** | Your own working copy. Changes stay there until they're reviewed. |
| **Commit** | Save a checkpoint of your changes, with a short note about what changed |
| **Push** | Send your commits up to GitHub |
| **Pull request (PR)** | A request for someone to review your branch before it's added to the main copy |
| **SCORM package** | The `.zip` file the LMS uses to run and track the module |

You can ask the assistant to commit, push or open a pull request for you. Just say, for example, "Commit my changes and open a pull request."

## Coming back later

1. Open VS Code. It usually reopens the `ai-training` folder. If it doesn't, use **File → Open Recent**.
2. Check the branch name in the bottom-left corner. It should be your module's branch, for example `module/ai-and-student-data-v1.0`. If it isn't, ask the assistant: "Switch to my module branch."
3. Ask the assistant: "Where did we leave off?" It reads the module brief and tells you.
