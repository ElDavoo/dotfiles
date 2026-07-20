# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Nix flake defining the NixOS system configuration for a single host, `mattone` (Intel + NVIDIA laptop running Hyprland). User-level config for `dave` is managed with home-manager, integrated as a NixOS module (not standalone). nixpkgs tracks `nixos-unstable`.

## Commands

```bash
# Rebuild and switch (nh is configured with flake = this repo)
nh os switch

# Verify everything builds + all lints pass, without switching
nix flake check

# Format (alejandra is the flake formatter)
nix fmt

# Lint individually (statix must run from the repo root so statix.toml is honored)
statix check .
deadnix .

# Edit an encrypted secret (uses ~/.config/sops/age/keys.txt)
sops secrets/<file>
```

`nix flake check` runs alejandra, statix, and deadnix as checks plus a full build of the `mattone` toplevel — run it before committing. `statix.toml` disables the `repeated_keys` lint because `foo.bar = x; foo.baz = y;` is intentional idiom here.

## Structure

- `flake.nix` — inputs, overlays (claude-code, firefox-addons), the single `nixosConfigurations.mattone`, and the checks. `inputs` is passed to all modules via `specialArgs` / `extraSpecialArgs`.
- `configuration.nix` — imports `hosts/mattone` plus every file in `modules/`. New system-level modules go in `modules/` and get added here.
- `home.nix` — imports every file in `home/`. New user-level modules go in `home/` and get added here.
- `hosts/mattone/` — hardware-specific config (nixos-hardware imports, storage, hostname).
- `home/config/` — raw Hyprland and waybar config files, deployed as **out-of-store symlinks** via `home/desktop.nix` (`mkOutOfStoreSymlink`). Edits to these take effect without a rebuild, but the repo must live at `~/git/dotfiles`. The active Hyprland config is `hyprland.lua` (hyprland.conf is a fallback). Waybar itself, hypridle/hyprlock/hyprpaper, wofi, and dunst are managed natively in Nix (`home/waybar.nix`, `home/services.nix`, etc.) — only the config in `home/config/` bypasses the store.

## Secrets

Secrets are sops-nix encrypted files in `secrets/`, decrypted at activation to `/run/secrets` using the host SSH key (`/etc/ssh/ssh_host_ed25519_key`). Keys and creation rules live in `.sops.yaml`; each secret is declared in `modules/secrets.nix`. Never commit plaintext secrets — add new ones by encrypting with `sops` and declaring them in that module.

## Conventions

- Comments in the codebase are often in Italian; that's fine to continue.
- Commit messages are lowercase, imperative, concise (e.g. "nixify wofi and dunst with a themed look").
