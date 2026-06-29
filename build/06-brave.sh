#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Brave Browser Install + Default Flatpak Cleanup
###############################################################################
# Installs Brave from the official Brave RPM repository at image build time so
# enterprise policy (mandatory at /etc/brave/policies/managed/family.json,
# copied from system_files in 02-system-config.sh) applies system-wide on
# first launch.
#
# Also removes Flatpak preinstall entries for Brave, Firefox, and Obsidian
# from bluefin's default suite so kids don't end up with duplicate Brave
# launchers (one policied RPM, one un-policied Flatpak) or apps not chosen
# for this image.
###############################################################################

echo "::group:: Install Brave Browser"

# Import Brave's package signing key
rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

# Add Brave's official Fedora-compatible RPM repository
curl -fsSL https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo \
    -o /etc/yum.repos.d/brave-browser.repo

dnf5 install -y brave-browser

# Repos don't work at runtime in bootc images — remove after install
rm -f /etc/yum.repos.d/brave-browser.repo

echo "::endgroup::"

###############################################################################
# Remove unwanted apps from bluefin's default Flatpak preinstall list
###############################################################################
echo "::group:: Trim default Flatpak preinstall"

DEFAULT_PREINSTALL=/etc/flatpak/preinstall.d/default.preinstall

if [[ -f "${DEFAULT_PREINSTALL}" ]]; then
    # Filter out [Flatpak Preinstall <id>] blocks for apps we don't want.
    # A block runs from its section header to the next section header, so
    # we toggle a skip flag on header match.
    awk '
        /^\[Flatpak Preinstall com\.brave\.Browser\]/      { skip = 1; next }
        /^\[Flatpak Preinstall org\.mozilla\.firefox\]/    { skip = 1; next }
        /^\[Flatpak Preinstall md\.obsidian\.Obsidian\]/   { skip = 1; next }
        /^\[Flatpak Preinstall /                            { skip = 0 }
        !skip                                               { print }
    ' "${DEFAULT_PREINSTALL}" > "${DEFAULT_PREINSTALL}.new"
    mv "${DEFAULT_PREINSTALL}.new" "${DEFAULT_PREINSTALL}"
else
    echo "No /etc/flatpak/preinstall.d/default.preinstall found — bluefin base may not ship one. Nothing to trim."
fi

echo "::endgroup::"

echo "Brave install + Flatpak trim complete!"
