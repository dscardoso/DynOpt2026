# Setup for Dynamic Optimization with Open-Source Tools

This page gets you set up for the workshop using your browser, with nothing to install. Follow the steps in order and a setup run should take about 15 minutes.

## What you need

- A web browser. Chrome, Edge, Firefox, or Safari should work.
- A free GitHub account. Step 1 below creates one if you do not have it.
- Nothing else. You do not need to install Julia or VS Code, and you do not need fork the workshop repository.

Everything runs in a GitHub Codespace, which is a VS Code editor that runs in your browser on a machine GitHub provides. Julia 1.12.7 and every package we use are already installed in it.

If your institution blocks Codespaces, or you would rather work on your own machine, see [Local install (optional)](#local-install-optional) at the end.

## Step 1: GitHub account

If you already have a GitHub account, sign in and go to Step 2.

1. Go to https://github.com/signup.
2. Enter your email, pick a password, and pick a username. If you have a university address, using it might give you access to Education benefits.
3. Confirm the email GitHub sends you.
4. Choose the free plan when you are asked.

The free plan is all we need. Codespaces usage is billed to your own GitHub account, and the free personal allowance is 120 core-hours and 15 GB of storage per month. Our Codespace uses a 2-core machine, so the three sessions use a small fraction of that. GitHub will not charge you unless you have added a payment method and raised your spending limit yourself.

If you have a valid `.edu` email, **I highly recommend you sign up for GitHub using your university email** and request the [GitHub Education benefits](https://github.com/education/students). It will give you a bunch of free add-ons, including more compute hours.

## Step 2: Open the Codespace

1. Go to the workshop repository: https://github.com/dscardoso/DynOpt2026
2. Click the green **Code** button near the top right.
3. In the small panel that opens, click the **Codespaces** tab.
4. Click **Create codespace on main**.

Do not click Fork and do not download the ZIP. Opening a Codespace on the repository gives you your own private copy of the files, running on a machine GitHub provides, and your edits stay there between sessions.

A new browser tab opens and shows a black screen with setup log messages. The Codespace is downloading the prebuilt image that holds Julia and the packages. The first time, this takes a few minutes, since the image is about 900 MB. Later openings take under a minute.

When it is ready you see the VS Code editor: a file tree on the left with `exercises`, `slides`, `solutions`, and `setup`, and a welcome tab in the middle.

## Step 3: Run the smoke test

The smoke test is a short script that checks Julia, the packages, and the solver. Run it once before the first session.

1. Open a terminal inside the Codespace. Use the **Terminal** menu, then **New Terminal**. The keyboard shortcut is Ctrl+` (control plus the backtick key, top left of most keyboards).
2. A terminal panel opens at the bottom. Click in it and type this, then press Enter:

```bash
julia --project=. setup/smoke_test.jl
```

The script prints numbered checks as it goes. In the Codespace it takes about 15 seconds. On a local install the first run takes a minute or two, because Julia compiles the packages on first use. If it works, the last line is exactly:

```
SMOKE TEST PASSED
```

That is the whole test. If you see that line, you are ready.

## Step 4: Try the editor

One more thing to confirm because this is how we run code during the sessions.

1. In the file tree on the left, open the `exercises` folder and click `s1_warmup.jl`.
2. Put the cursor on the first line of code in the file.
3. Press **Shift+Enter**.

The first time you do this, a Julia REPL starts in a panel at the bottom. It takes a few seconds. Then the line you selected runs, and its result appears in that panel. After that, Shift+Enter is instant.

If the line runs and you see a result, the Julia extension for VS Code is working and your setup is complete.

## If something fails

If the smoke test prints `SMOKE TEST FAILED`, it also prints diagnostic output that tells you what went wrong. Do the same if the Codespace never finishes opening, or if Shift+Enter does nothing in Step 4.

1. Select everything the script printed in the terminal, from the command you typed down to the last line.
2. Copy it.
3. Email it to dcardoso@illinois.edu, pasted into the message.

I will try to help you fix it as my time allows.

Please run the smoke test by **Thursday, September 24**, so we have time to sort out problems before the first session on Saturday.


## Between sessions

**Stopping.** You do not need to stop the Codespace by hand. It stops on its own after 30 minutes of no activity, and a stopped Codespace uses no compute. If you want to close it, just close the browser tab.

**Reopening.** Open the same Codespace again, do not create a new one. A new one starts empty of your work. Two ways to get back to yours:

- Go to https://github.com/codespaces and click the Codespace in the list, or
- Go to https://github.com/dscardoso/DynOpt2026, click **Code**, click the **Codespaces** tab, and click the Codespace already listed there.

Your files and your edits are where you left them. GitHub deletes a Codespace after 30 days of no use, which is well past our three weekly sessions.

**Before sessions 2 and 3.** I add the materials for each session to the repository shortly before we meet. To pull them into your Codespace, open a terminal and run:

```bash
git pull
```

This only adds the new files. Nothing you wrote in session 1 is overwritten.

If `git pull` complains about local changes, it means you edited a file that I also changed. Run these three commands, one at a time:

```bash
git stash
git pull
git stash pop
```

`git stash` sets your edits aside. `git pull` brings in the new files. `git stash pop` puts your edits back on top. If anything still looks wrong after that, email me and keep working from the `solutions/` folder in the meantime.

## Local install (optional)

The Codespace is the supported path. During the sessions I can only help with Codespace problems, because a local setup can fail in ways I cannot see or reproduce while teaching. If you install locally, please also open a Codespace as a backup.

1. **Install Julia 1.12.7** with juliaup, the Julia version manager. Follow the instructions at https://julialang.org/install/ for your operating system, then run:

```bash
juliaup add 1.12.7
juliaup default 1.12.7
```

2. **Install VS Code** from https://code.visualstudio.com/, open it, go to the Extensions panel on the left, search for `julialang.language-julia`, and install the extension named **Julia**.

3. **Get the repository.** Either clone it:

```bash
git clone https://github.com/dscardoso/DynOpt2026.git
```

or, if you do not have Git, go to https://github.com/dscardoso/DynOpt2026, click the green **Code** button, click **Download ZIP**, and unzip it somewhere you can find again.

4. **Open the folder in VS Code.** File menu, then Open Folder, then pick the `DynOpt2026` folder.

5. **Install the packages.** Open a terminal in that folder and run:

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

This downloads and compiles everything the workshop uses. It takes several minutes and only happens once.

6. **Run the smoke test**, exactly as in Step 3 above:

```bash
julia --project=. setup/smoke_test.jl
```

If you used the ZIP instead of `git clone`, `git pull` will not work for you before sessions 2 and 3. Download the ZIP again and replace your folder, keeping a copy of any file you edited.

## What is in the repository

- `exercises/`: the scripts we fill in together during each session.
- `solutions/`: complete versions of those scripts, for after the session or if you fall behind.
- `slides/`: the slides and notes for each session, added before each session. Session 1 is also online: [slides](https://raw.githack.com/dscardoso/DynOpt2026/main/slides/session_1/DYNOPT_1_slides.html) and [notes](https://raw.githack.com/dscardoso/DynOpt2026/main/slides/session_1/DYNOPT_1_notes.html).
- `setup/`: this file and the smoke test script.

## Schedule

All three sessions run 2:00 to 3:30 PM Central Time.

| Session | Date | Topic |
| --- | --- | --- |
| 1 | Friday, September 26, 2026 | Julia, optimization, and a static reservoir |
| 2 | Friday, October 3, 2026 | The Bellman equation on a discrete state |
| 3 | Friday, October 10, 2026 | Continuous state: finite and infinite horizon |


