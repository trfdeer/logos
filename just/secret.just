# Secrets management
set default-list

ROOT := justfile_directory()

SECRET_FILES := "identities devices sshHosts outConfig"

RUNTIME_SECRETS_DIR := ROOT / ".runtime" / "secrets"

AGE_KEY := `op read op://sqwer/sqwer_age/password`

# Decrypt and initialize secrets
init:
    #!/usr/bin/env bash
    set -euo pipefail
    echo 'Initializing secrets...'
    git config core.hooksPath ".githooks"
    rm -rf "{{RUNTIME_SECRETS_DIR}}"
    mkdir -p "{{RUNTIME_SECRETS_DIR}}"
    for file in {{SECRET_FILES}}; do
      echo "→ decrypting $file.json"
      SOPS_AGE_KEY="{{AGE_KEY}}" sops \
        --output "{{RUNTIME_SECRETS_DIR}}/$file.json" \
        -d "{{ROOT}}/secrets/$file.json"
    done
    find "{{RUNTIME_SECRETS_DIR}}" -type f -exec git add -fN {} \;
    echo 'Done'

# Open encrypted file with sops
edit *ARGS:
    #!/usr/bin/env bash
    set -euo pipefail
    AGE_KEY=$(just secrets/get-age-key)
    SOPS_AGE_KEY="$AGE_KEY" sops {{ARGS}}

# Remove generated files
clean:
    echo 'Cleaning secrets...'
    rm -rf "{{RUNTIME_SECRETS_DIR}}"
