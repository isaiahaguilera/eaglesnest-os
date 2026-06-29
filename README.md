# eaglesnest-os

[![Build Stable Image](https://github.com/isaiahaguilera/eaglesnest-os/actions/workflows/build.yml/badge.svg)](https://github.com/isaiahaguilera/eaglesnest-os/actions/workflows/build.yml)

A custom bootc operating system image for homeschool/family laptops. Based on [Universal Blue](https://universal-blue.org/) and [Bluefin](https://projectbluefin.io), bootstrapped from the patterns established in [greatlem0n-os](https://github.com/isaiahaguilera/greatlem0n-os).

This image strips out developer / remote-admin tooling and provides a base for adding education software, parental controls, and family-friendly defaults.

---

## First-time Setup Checklist

Run these once after the repo is bootstrapped locally. Claude (or you) can run steps 1, 2, 3 directly via `gh`.

```bash
# 0. From inside the eaglesnest-os/ directory:
cd ~/Documents/Projects/bootc-images/eaglesnest-os

# 1. Create the GitHub repository (public so GHCR images are pullable)
gh repo create eaglesnest-os --public --source=. --remote=origin \
  --description "Custom bootc OS image for homeschool/family use"

# 2. Stage and push the initial commit (already prepared locally)
git push -u origin main

# 3. Upload the cosign private key as the SIGNING_SECRET GitHub secret
gh secret set SIGNING_SECRET < cosign.key

# 4. SECURELY back up cosign.key (password manager / encrypted drive),
#    then delete the local copy.
#    Without this key you cannot sign new images for this repo.
shred -u cosign.key

# 5. Add the new repo to your self-hosted Renovate config (manual)
#    Include "isaiahaguilera/eaglesnest-os" in the repositories list.

# 6. The first build runs automatically on push. To trigger manually later:
gh workflow run build.yml --repo isaiahaguilera/eaglesnest-os

# 7. Once :stable is built, deploy on a kids laptop:
sudo bootc switch ghcr.io/isaiahaguilera/eaglesnest-os:stable
sudo systemctl reboot
```

---

## What's Different from greatlem0n-os

This image was bootstrapped from greatlem0n-os and intentionally **does not include** the following for family fit:

**Removed remote-admin / network surface:**
- SSH service + sshd hardening
- fail2ban brute-force protection
- RDP polkit rules
- udev wheel hardware-access rules
- Tailscale exit-node configuration (sysctl + ujust toggle)
- cloudflared tunnel daemon

**Removed developer / AI tooling:**
- VS Code from Microsoft repo
- VS Code AI extensions (Claude Code, Copilot, ChatGPT)
- Claude Desktop app
- Development Brewfile (shellcheck, cosign)
- Dev shell tools: tmux, keychain, stow
- `configure-dev-groups`, `install-jetbrains-toolbox`, `toggle-sudo` ujust commands

**Also removed for family fit:**
- `ghostty` terminal (kids don't need a power-user terminal)
- Flatpak Firefox, Flatpak Obsidian, Flatpak Brave entries from bluefin's default preinstall list (Firefox/Obsidian don't ship; Brave is installed as RPM instead — see below)

**Kept (from greatlem0n-os):**
- Bluefin :stable base, Tailscale client (no exit node), Homebrew default + fonts Brewfiles
- gparted, zsh/fish/git/rclone
- Firefox RPM removal, fastfetch branding skeleton
- Container signature verification (cosign + sigstore policy)
- Bluefin default Flatpak suite minus the entries called out above

## New for Family Use

- **Cloudflare WARP** (Cloudflare One Client) installed and `warp-svc.service` enabled at boot for network-level filtering via Cloudflare Zero Trust Gateway (full tunnel + TLS decryption). One-time interactive enrollment per laptop; switch lock, auto-connect, and mode are enforced by the org's Device Settings Profile in the Zero Trust dashboard.
- **Cloudflare Gateway root CA** installed into `/etc/pki/ca-trust/source/anchors/` so decrypted HTTPS doesn't trip browser certificate warnings.
- **Brave Browser (RPM)** with mandatory enterprise policy at `/etc/brave/policies/managed/family.json`:
  - Tor windows, Brave Rewards, Brave Wallet, Brave VPN, Brave AI Chat (Leo), Brave Sync, P3A telemetry, IPFS gateway, WebTorrent — all off
  - Incognito mode disabled (private browsing hides local activity from spot-checks; WARP still logs the network side)
  - Google set as the default and only search engine
- `custom/brew/education.Brewfile` — placeholder for education CLI tools
- `custom/flatpaks/education.preinstall` — placeholder with GCompris, Tux Math, Stellarium, etc. candidates
- `custom/ujust/family.just` — `install-education`, `parental-controls`

## Parental Controls & Filtering

**Primary layer (network):** Cloudflare Zero Trust Gateway via WARP.

After installing this image on a laptop, enroll it once via `warp-cli` (consult `warp-cli --help` for the current registration subcommand — Cloudflare renames it occasionally). A browser opens, the assigned user signs in to Cloudflare Access, and the device picks up its policy from the Zero Trust dashboard.

Filtering categories (adult, malware, etc.), per-policy bypasses, TLS inspection, switch lock, auto-connect, and device lockout rules are all configured in the [Cloudflare Zero Trust dashboard](https://one.dash.cloudflare.com/), not in this image.

**Future layers to evaluate (defense in depth):**
- **Per-user app gating** — `malcontent` (GNOME Parental Controls) for app launching/browser content filtering (shipped in Bluefin base; not yet configured)
- **Screen time** — gnome-screen-time (if/when stable) or third-party
- **Per-kid accounts** — provision via cloud-init or first-boot script with restricted groups

## Roadmap

- [ ] Pick and add education Flatpaks (GCompris, Stellarium, etc.)
- [ ] Dry-run malcontent setup with a test user account
- [ ] Replace lemon-themed branding (logos, fastfetch ANSI art) with eagle nest assets
- [ ] Add per-kid user provisioning
- [ ] Add screen-time tooling

---

## Build System

- Automated builds via GitHub Actions on every push to `main` (`:stable` tag)
- Self-hosted Renovate updates base images and dependencies every 6 hours
- Automatic cleanup of old images (90+ days)
- Validation workflows for shellcheck, Brewfile, Flatpak ID verification, justfile
- Image signing with cosign (enabled — requires SIGNING_SECRET in repo secrets)

## Local Testing

```bash
just build              # Build container image
just build-qcow2        # Build VM disk image
just run-vm-qcow2       # Test in browser-based VM
```

## Resources

- [AGENTS.md](AGENTS.md) — development guide (copied from greatlem0n-os, applies here too)
- [greatlem0n-os](https://github.com/isaiahaguilera/greatlem0n-os) — sibling image (Isaiah's daily driver)
- [Universal Blue](https://universal-blue.org/) / [Bluefin](https://projectbluefin.io)
- [bootc](https://containers.github.io/bootc/)
