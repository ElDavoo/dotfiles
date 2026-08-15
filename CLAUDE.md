# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Nix flake defining the NixOS system configuration for two hosts:

- `mattone` — Intel + NVIDIA laptop running Hyprland, the main machine.
- `lenuovo` — Lenovo IdeaPad Flex 15 (Bay Trail N3520, 4 GB RAM, iGPU only), a slim install that shares the base but skips the heavy modules.

User-level config for `dave` is managed with home-manager, integrated as a NixOS module (not standalone). nixpkgs tracks `nixos-unstable`.

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

`nix flake check` runs alejandra, statix, and deadnix as checks plus a full build of every host toplevel — run it before committing. On `lenuovo` that also builds mattone's closure (NVIDIA, Steam, hermes), which is slow on that hardware; build a single host with `nix build .#nixosConfigurations.lenuovo.config.system.build.toplevel` instead. `statix.toml` disables the `repeated_keys` lint because `foo.bar = x; foo.baz = y;` is intentional idiom here.

## Structure

- `flake.nix` — inputs, overlays (claude-code, firefox-addons), the `mkHost` helper, one `nixosConfigurations.<host>` per machine, and the checks. `inputs` is passed to all modules via `specialArgs` / `extraSpecialArgs`. Flake-input NixOS modules that only one host needs (e.g. hermes-agent) are passed as that host's `extraModules`.
- `configuration.nix` — the **shared** module set, imported by every host. Modules that are heavy or hardware-bound do *not* go here.
- `home.nix` — imports every file in `home/`. New user-level modules go in `home/` and get added here. Per-host differences in home-manager are gated on `osConfig.networking.hostName` (see `home/packages.nix`, `home/waybar.nix`).
- `hosts/<host>/` — hardware-specific config (nixos-hardware imports, bootloader, storage, hostname) plus the `modules/` that only that host wants.
- `modules/` — system-level modules. Shared ones are listed in `configuration.nix`; host-specific ones (`gaming.nix`, `printing.nix`, `power.nix`, `hermes.nix`, `secrets.nix`, `spicetify.nix`, `virtualization.nix`, `controller.nix`, `gparted-live.nix`) are imported from `hosts/mattone/default.nix`.
- `home/config/` — raw Hyprland and waybar config files, deployed as **out-of-store symlinks** via `home/desktop.nix` (`mkOutOfStoreSymlink`). Edits to these take effect without a rebuild, but the repo must live at `~/git/dotfiles`. The active Hyprland config is `hyprland.lua` (hyprland.conf is a fallback). Waybar itself, hypridle/hyprlock/hyprpaper, wofi, and dunst are managed natively in Nix (`home/waybar.nix`, `home/services.nix`, etc.) — only the config in `home/config/` bypasses the store.

## Secrets

Secrets are sops-nix encrypted files in `secrets/`, decrypted at activation to `/run/secrets` using the host SSH key (`/etc/ssh/ssh_host_ed25519_key`). Keys and creation rules live in `.sops.yaml`; each secret is declared in `modules/secrets.nix`. Only hosts whose key is listed in `.sops.yaml` can import that module — currently `mattone` alone, so `lenuovo` does not import it. To add a host: `ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub`, add the key to `.sops.yaml`, then `sops updatekeys secrets/*`. Never commit plaintext secrets — add new ones by encrypting with `sops` and declaring them in that module.

## Conventions

- Comments in the codebase are often in Italian; that's fine to continue.
- Commit messages are lowercase, imperative, concise (e.g. "nixify wofi and dunst with a themed look").
