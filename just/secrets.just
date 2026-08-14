# Secrets management

SECRET_FILES := "identities devices sshHosts outConfig"
DECRYPTED_DIR := "secrets/decrypted"

[private]
get-age-key:
    @op read op://sqwer/sqwer_age/password

# Decrypt and initialize secrets
init:
    #!/usr/bin/env bash
    set -euo pipefail
    echo 'Initializing secrets...'
    git config core.hooksPath ".githooks"
    rm -rf "{{DECRYPTED_DIR}}"
    mkdir -p "{{DECRYPTED_DIR}}"
    AGE_KEY=$(just secrets/get-age-key)
    for file in {{SECRET_FILES}}; do
      echo "→ decrypting $file.json"
      SOPS_AGE_KEY="$AGE_KEY" sops \
        --output "{{DECRYPTED_DIR}}/$file.json" \
        -d "secrets/$file.json"
    done
    find "{{DECRYPTED_DIR}}" -type f -exec git add -fN {} \;
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
    rm -rf "{{DECRYPTED_DIR}}"
