---
name: commit-conventions
description: "Use when writing, revising, or reviewing any git commit message in any repo: Conventional Commits subject lines, breaking-change markers, resolving the project's scope list, and Keep a Changelog bodies that feed generated changelogs (e.g. git-cliff)."
---

# Commit Conventions

Project-agnostic commit-message rules. Repo-specific lists (like a scope table) are
_resolved from the repository_, never assumed from this skill.

## Before writing a message

This is the user's default convention and applies to every repository, including ones
whose history predates it. Switching a project over mid-stream is expected — a few
non-conforming commits in the log are not a reason to keep writing them.

1. Look for a repo-declared convention, in this order: `AGENTS.md`, `CLAUDE.md`,
   `CONTRIBUTING.md`, `.github/CONTRIBUTING.md`, commitlint / semantic-release config.
   If one exists, it **overrides** this skill for that repo.
2. Otherwise write Conventional Commits anyway. Consult `git log --format=%s -n 30` only
   to learn which scopes and types are already in play (see below), not to decide whether
   the format applies.
3. If the repo enforces something mechanically (commitlint, a git hook) and this skill
   would conflict, follow the enforcement and say so rather than fighting the hook.

## Subject

Format: `type(scope): subject`

- Imperative mood ("add", "fix", not "added" / "adds"), lower case, no trailing period.
- Aim for ≤ 50 characters after the prefix; the whole subject ≤ 72.
- Body separated by one blank line; wrap at ~72 columns.

Types: `feat`, `fix`, `refactor`, `perf`, `build`, `ci`, `docs`, `style`, `test`, `chore`, `revert`.
A repo may narrow or extend this list — its own list wins.

This prefix is load-bearing: changelog generators like
[git-cliff](https://git-cliff.org/docs/) group commits by regexes over it (`^feat`,
`^fix`, …), so a type outside the repo's `commit_parsers` list lands in "Other" or is
filtered out of the changelog entirely (`filter_unconventional`). Use the exact spellings
above — no ad-hoc types. `chore(release):` and `chore(deps…):` shapes are skipped by
git-cliff's default parsers — leave those to release automation, don't hand-write them.

### Breaking changes

Anything that breaks consumers must be marked in **both** places, so tools derive the
major version bump and highlight the commit:

- `!` before the colon: `feat(home)!: rename the opencode settings option`
- a `BREAKING CHANGE:` footer in the body explaining what broke and how to migrate:

  ```text
  BREAKING CHANGE: `logos.home.opencode.settings` replaces `extraConfig`;
  move existing values to the new option.
  ```

git-cliff flags such commits `[**breaking**]` in the changelog and bumps major on
`--bumped-version`; `feat` alone is only a minor, `fix` only a patch. Breaking commits may
also be protected from exclusion via `protect_breaking_commits`.

## Scopes

A scope names the _area of the codebase_ the change belongs to. Scopes come from a closed,
project-owned list — either declared by the repo or agreed with the user once and written
down. **Never invent one silently, commit by commit.**

Resolve them in this order:

1. **Declared table.** If the repo defines scopes (in `AGENTS.md`, `CONTRIBUTING.md`, or
   commitlint `scope-enum`), use exactly those. Never coin a variant, plural, or synonym.
   If a change fits none of them, omit the scope.
2. **Derive from the tree.** If nothing is declared, candidate scopes are the repo's
   meaningful top-level dirs or package/module names (e.g. `api`, `ui`, `docs`, `infra`).
   Reuse any scope already present in `git log`; when the history has none — a repo adopting
   the convention for the first time — propose the derived list to the user and offer to
   record it in `AGENTS.md` or `CONTRIBUTING.md` so later commits resolve it from step 1
   instead of re-deriving it.
3. **No scope.** Omit the prefix and write `type: subject` when the change spans several
   areas, when the repo has no scope convention, or when the repo's list has no entry
   that fits.

New top-level area with no matching scope: add a row to the repo's own table **in the
same commit** that first uses it, and mention that in the body. A user-level skill is not
the place for a per-project list — it would leak one repo's layout into every other one.

Granularity: never scope by individual file, hostname, feature branch, or ticket number.
Use one scope per commit; split the commit instead of writing `(home,secrets)`.

## Body — Keep a Changelog sections

Templates like git-cliff's `keepachangelog` build changelog sections from commit bodies in
this format, so no manual `CHANGELOG` file is needed. (With git-cliff's _default_ template
only the subject line is rendered — always write a subject that stands on its own.)
Use these labels, only the ones that apply, in this order:

`Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`

- Each label is a heading line followed by `-` bullets — one bullet per user-visible change.
- Default label from the type: `feat` → `Added`; `fix` → `Fixed`;
  `refactor` / `perf` / user-visible `chore` → `Changed`.
- Content beats the type default: deprecations → `Deprecated`, removals → `Removed`,
  security fixes → `Security`.
- Describe what a user or operator observes, not which file was edited.
- Skip the body for `docs`, `style`, `ci`, and internal `build` commits.

## Examples

With a declared scope:

```text
feat(home): add opencode home module

Added:
- `logos.home.opencode` option managing OpenCode (package, settings, TUI)
- `oc` shell alias for opencode
```

No fitting scope, spanning areas:

```text
fix: correct flake output for standalone home configs

Fixed:
- Host entries in `homeConfigurations` no longer inherit the wrong system name
```

Removal and security content override the type default:

```text
chore(secrets): drop legacy age key handling

Removed:
- `secrets/age.key` fallback path
Security:
- Secrets are now decrypted only through SOPS with the host key
```

## Checking your work

Before finishing, confirm:

- The type is from the allowed list and describes the change, not the effort — changelog
  generators key off the exact prefix.
- If the change breaks consumers, `!` and a `BREAKING CHANGE:` footer are both present.
- The scope exists in the repo's own list, or is absent.
- Nothing in the message references files the diff does not touch.
- Bullets are user-visible; no "WIP", "fixup", "address review", or ticket-only prose.
- `git diff --cached` matches what the message claims. Stage and amend if it does not.
