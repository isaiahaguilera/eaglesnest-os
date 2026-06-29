#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Cloudflare WARP Install + Gateway Cert Trust
###############################################################################
# Installs the Cloudflare One Client (WARP) for network-level filtering via
# Cloudflare Zero Trust Gateway, and installs the org's Gateway root CA
# certificate into the system trust store so TLS decryption works without
# browser warnings.
#
# Enrollment is interactive (post-install, per-laptop):
#   sudo warp-cli teams-enroll <team-name>
#   warp-cli connect
# Switch lock, auto-connect, and service mode are managed via Cloudflare
# Zero Trust Device Settings Profiles (dashboard), not via MDM. No mdm.xml
# is shipped so the team name never gets baked into a public image.
###############################################################################

echo "::group:: Install Cloudflare WARP"

# Import Cloudflare's package signing key (refreshed 2025-09-12)
rpm --import https://pkg.cloudflareclient.com/pubkey.gpg

# Add Cloudflare WARP RPM repository
# Their CentOS 8 builds are the supported channel for RHEL/Fedora-family hosts
curl -fsSL https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo \
    -o /etc/yum.repos.d/cloudflare-warp.repo

# Cloudflare ships cloudflare-warp built against CentOS 8, where the tray
# applet depends on webkit2gtk3. Fedora has shipped webkit2gtk4.1 for years
# and dropped the old name, so dnf cannot resolve the dep. warp-svc and
# warp-cli — the only pieces we actually use — don't link against webkit at
# all; only the (unused-on-this-image) tray applet does. Download the RPM and
# install with --nodeps to bypass the stale dep.
# dnf5 download will pull every arch the repo ships (x86_64 + aarch64) unless
# we filter — and rpm refuses to install both at once. Pin to host arch.
WARP_ARCH=$(uname -m)
WARP_DOWNLOAD_DIR=$(mktemp -d)
trap 'rm -rf "${WARP_DOWNLOAD_DIR}"' EXIT
dnf5 download --arch="${WARP_ARCH}" --destdir="${WARP_DOWNLOAD_DIR}" cloudflare-warp
rpm -ivh --nodeps "${WARP_DOWNLOAD_DIR}"/cloudflare-warp-*."${WARP_ARCH}".rpm

# Repos don't work at runtime in bootc images — remove after install
rm -f /etc/yum.repos.d/cloudflare-warp.repo

# Disable the GUI tray applet's XDG autostart — it can't launch without
# webkit2gtk3 and we manage WARP via warp-cli + dashboard policies.
rm -f /etc/xdg/autostart/cloudflare-warp*.desktop \
    /etc/xdg/autostart/warp-taskbar*.desktop

echo "::endgroup::"

###############################################################################
# Install Cloudflare Gateway CA into system trust store
###############################################################################
echo "::group:: Install Cloudflare Gateway CA"

# Both .crt and .pem are copied — Cloudflare ships both formats for compatibility
install -D -m 0644 /ctx/custom/cloudflare/certificate.crt \
    /etc/pki/ca-trust/source/anchors/cloudflare-gateway.crt
install -D -m 0644 /ctx/custom/cloudflare/certificate.pem \
    /etc/pki/ca-trust/source/anchors/cloudflare-gateway.pem

update-ca-trust

echo "::endgroup::"

###############################################################################
# Enable WARP system service at boot
###############################################################################
echo "::group:: Enable warp-svc.service"

systemctl enable warp-svc.service

echo "::endgroup::"

echo "Cloudflare WARP install complete!"
