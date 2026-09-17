---
name: commit-conventions
description: "Use when writing, revising, or reviewing any git commit message in any repo: Conventional Commits subject lines, resolving the project's scope list, and Keep a Changelog bodies that feed generated changelogs."
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

Types: `feat`, `fix`, `refactor`, `perf`, `build`, `ci`, `docs`, `style`, `chore`, `revert`.
A repo may narrow or extend this list — its own list wins.

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

Release tooling often builds changelogs from commit bodies, so no manual `CHANGELOG` file
is needed. Use these labels, only the ones that apply, in this order:

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
- `sqwer.home.opencode` option managing OpenCode (package, settings, TUI)
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

- The type is from the allowed list and describes the change, not the effort.
- The scope exists in the repo's own list, or is absent.
- Nothing in the message references files the diff does not touch.
- Bullets are user-visible; no "WIP", "fixup", "address review", or ticket-only prose.
- `git diff --cached` matches what the message claims. Stage and amend if it does not.
