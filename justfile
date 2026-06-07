set lazy
set quiet

secret_files := "identities devices sshHosts outConfig"
age_key := `op read op://sqwer/sqwer_age/password`
decrypted_dir := "secrets/decrypted"

COMMAND := style("command")
WARNING := style("warning")

# List available recipes
@help:
	just --list

# Decrypt and initialize secrets
secret-init:
	@echo '{{COMMAND}}Initializing secrets...{{NORMAL}}'

	# enable repo hooks
	git config core.hooksPath ".githooks"

	# prepare output directory
	rm -rf "{{decrypted_dir}}"
	mkdir -p "{{decrypted_dir}}"

	# decrypt secrets
	for file in {{secret_files}}; do \
		echo '{{WARNING}}→ decrypting '"$file"'.json{{NORMAL}}'; \
		SOPS_AGE_KEY={{age_key}} sops \
			--output "{{decrypted_dir}}/$file.json" \
			-d "secrets/$file.json"; \
	done

	# make git aware of decrypted files for nix flakes
	find "{{decrypted_dir}}" -type f -exec git add -fN {} \;

	@echo '{{COMMAND}}Done{{NORMAL}}'

# Open decrypted file in vscode for editing
secret-edit file:
	SOPS_AGE_KEY={{age_key}} EDITOR="code --wait" sops {{file}}

# Remove generated files
secret-clean:
	@echo '{{WARNING}}Cleaning secrets...{{NORMAL}}'
	rm -rf secrets/decrypted

# Build system image. Supported types: tarball isoImage
build-image host type *args:
  nix build .#nixosConfigurations.{{host}}.config.system.build.{{type}} {{args}}

# Build LXC container image tarball
build-lxc host *args:
  just build-image {{host}} tarball {{args}}

# Build ISO image
build-iso host *args:
  just build-image {{host}} isoImage {{args}}

# Build WSL tarball
build-wslbuilder host *args:
  just build-image {{host}} tarballBuilder

# Install `output` to `target` host
deploy output host port *args:
  nixos-anywhere --target-host "root@{{host}}" -p "{{port}}" -f ".#{{output}}" {{args}}

switch output host *args:
  nh os switch .#{{output}} --target-host {{host}}
