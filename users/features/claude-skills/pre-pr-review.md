---
name: pre-pr-review
description: Review a local branch before it becomes a PR, with a second Claude session in a new Herdr tab. Writes the PR description, has the reviewer check the branch and the description, then verifies its findings and applies the accurate ones in this session. Use when the user asks for a pre-PR review, a second-opinion review of a local branch, or /pre-pr-review. Not for reviewing PRs that already exist on GitHub. Requires HERDR_ENV=1.
---

# PR review with a second session

The reviewer starts cold, so it knows nothing this session assumed. Its
findings are claims to check, not instructions: verify each one before
changing anything.

Arguments, if given: the branch (default: the current one) and the base
(default: the repo's main branch).

## 1. Check the preconditions

```bash
test "${HERDR_ENV:-}" = 1   # otherwise say so and stop
git status --short           # uncommitted work isn't on the branch, so the reviewer won't see it
git log --oneline <base>..<branch>
git log --oneline @{u}..<branch> 2>/dev/null   # unpushed commits, if it has an upstream
```

If the branch has uncommitted changes the user meant to include, ask them
whether to commit first. Step 6 rewrites the branch's commits, so if any
are already pushed, ask the user before going on.

## 2. Write the PR description

Write it to the scratchpad as `pr-description.md`. Put the title on the
first line, then `## Summary` (what changed and why, with any trade-offs
the reader should weigh) and `## Test plan` (a checklist: what was run,
and what is still unchecked). Each claim must be one the code supports;
the reviewer checks it.

Leave out attribution lines here. When the PR is opened, add them only if
the repo's conventions (or the user's memory) call for them.

## 3. Start the reviewer

Pass every flag: `herdr tab create` with no arguments still creates a tab.

```bash
tab=$(herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$(git rev-parse --show-toplevel)" --label review --no-focus)
pane=$(jq -r .result.root_pane.pane_id <<<"$tab")
herdr agent start pr-reviewer --kind claude --pane "$pane" --timeout 60000
```

If `pr-reviewer` is already taken by a live agent, choose another name.

## 4. Send the review prompt

Fill in the branch, base and the description's absolute path. Add any
checks specific to this change, such as pinned SHAs or moved files, at the
end of "Look for".

```text
Review the branch <branch> against <base> (git diff <base>...<branch>;
commits via git log <base>..<branch>). Its PR description is in <path>;
check the description against the code as well. This is a read-only
review: do not edit files, commit, push or open a PR. Look for
correctness bugs, risks, anything the change breaks elsewhere in the
repo, and inaccuracies in the description. Reply with a numbered list of
findings, each with file:line, severity (bug / risk / nit), the concrete
failure scenario, and a suggested fix. Say plainly if a category has
nothing.
```

```bash
herdr agent prompt pr-reviewer "<prompt>" --wait --timeout 900000 >/dev/null
herdr agent read pr-reviewer --source recent-unwrapped --lines 400
```

The Bash tool caps a call at 10 minutes. If the wait times out, the
prompt was still sent: wait again with `herdr agent wait pr-reviewer`
instead of sending it again. If the agent is `blocked`, read the pane and
ask the user before answering it. If the read cuts off the reply, ask the
reviewer to write the findings to a Markdown file in /tmp and reply with
only its path.

## 5. Verify each finding

For each finding, decide whether it is accurate before touching any
code:

- Reproduce it where you can, such as a small git repo in the
  scratchpad, a test, or the failing command.
- Where the finding is about a tool's or platform's behavior (GitHub
  Actions, a compiler), check it against the docs or a run. Don't just
  trust the reviewer.
- A finding can be accurate and still not worth fixing, for example a
  gap that already existed before this branch. Fixing the description
  so it doesn't over-claim is often the right answer.

## 6. Apply and report

- Before fixing anything, note the branch tip: `pre=$(git rev-parse HEAD)`.
- Fix the accurate findings in the commits they belong to, so the branch
  reads as if it had been right the first time, unless the repo's
  conventions or the user's memory say to keep review fixes separate.
  Commit each fix with `git commit --fixup=<sha>` against the commit that
  introduced the problem, or `--fixup=amend:<sha>` when the fix also
  changes what that commit's message says, writing the corrected message
  in full. Then `git rebase --autosquash <base>`, which needs no editor.
  If a fixup conflicts, resolve it, or `git rebase --abort` and ask the
  user.
- On a branch of several commits, run the checks on each one
  (`git rebase --exec '<test command>' <base>`), as a fix can land in an
  earlier commit than code that relies on it.
- Show the user what the review changed with
  `git range-diff <base> $pre HEAD`, and give them `$pre` to go back to.
- Correct the PR description where the review showed it was wrong.
- Run whatever checks the change calls for (tests, linters) again.
- Tell the user about each finding: fixed, fixed only in the
  description, or rejected, with the reason.

Don't push or open the PR unless the user asks. Leave the reviewer's tab
open so the user can read the full review. Close it only if asked
(`herdr tab close <tab_id>`).
