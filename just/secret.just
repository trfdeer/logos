# Secrets management
set quiet
set default-list

ROOT := justfile_directory()
SECRETS_DIR := ROOT / "secrets"
RUNTIME_DIR := ROOT / ".runtime"
SOPS := "secretspec run --scope sops -- sops"

SECRET_FILES := shell('ls ' + SECRETS_DIR + '/*.json | tr "\n" " "')
RUNTIME_FACTER_DIR := RUNTIME_DIR / "facter"

FACTER_FILES := shell('ls ' + SECRETS_DIR + '/facter/*.json | tr "\n" " "')
RUNTIME_SECRETS_DIR := RUNTIME_DIR / "secrets"

# Decrypt and initialize secrets
init: clean
    git config core.hooksPath ".githooks"
    mkdir -p {{RUNTIME_SECRETS_DIR}} {{RUNTIME_FACTER_DIR}}

    for f in {{FACTER_FILES}}; do {{SOPS}} --input-type binary --output-type binary -d "$f" | bzip2 -d > {{RUNTIME_FACTER_DIR}}/"$(basename "$f")"; done
    for f in {{SECRET_FILES}}; do {{SOPS}} --output {{RUNTIME_SECRETS_DIR}}/"$(basename "$f")" -d "$f"; done

    git add -fN -- {{RUNTIME_SECRETS_DIR}}/* {{RUNTIME_FACTER_DIR}}/*

# Open encrypted file with sops
[working-directory(ROOT)]
edit *ARGS:
    {{SOPS}} {{ARGS}}

# Fill in a temporary file, then bzip2-compress and sops-encrypt it into secrets/facter
edit-facter name:
    #!/usr/bin/env bash
    set -euo pipefail
    tmp="$(mktemp --suffix=.json)"
    trap 'rm -f "$tmp"' EXIT
    "${EDITOR:-nvim}" "$tmp"
    bzip2 -c "$tmp" | {{SOPS}} --input-type binary --output-type binary --encrypt /dev/stdin > {{SECRETS_DIR}}/facter/{{name}}.json

# Remove generated files
clean:
    #!/usr/bin/env bash
    set -euo pipefail

    for dir in {{RUNTIME_SECRETS_DIR}} {{RUNTIME_FACTER_DIR}}; do
        if [ -n "$(git ls-files "$dir")" ]; then
            git rm -r --cached --quiet --ignore-unmatch "$dir"
        fi
        rm -rf "$dir"
    done
