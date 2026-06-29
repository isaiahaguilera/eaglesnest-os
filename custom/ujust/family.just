# vim: set ft=make :
###################
### family.just
###################
## Family / homeschool convenience commands

# Install education tools from the education Brewfile
[group('Family')]
install-education:
    #!/usr/bin/env bash
    echo "Installing education tools via Homebrew..."
    brew bundle --file /usr/share/ublue-os/homebrew/education.Brewfile

# Placeholder for parental-control configuration
# TODO: implement once parental control approach is chosen
# (candidates: opensnitch, NextDNS / Pi-hole upstream, gnome-screen-time)
[group('Family')]
parental-controls:
    #!/usr/bin/env bash
    echo "Parental controls are not yet configured for this image."
    echo "See README.md 'Parental Controls & Filtering (TODO)' for plans."

# Show Cloudflare WARP status (registration, connection, current settings)
[group('Family')]
warp-status:
    #!/usr/bin/env bash
    set -e
    echo "== status =="
    warp-cli status || true
    echo
    echo "== account =="
    warp-cli account || true
    echo
    echo "== settings =="
    warp-cli settings || true

# Enroll this device in the family Cloudflare Zero Trust org.
# One-time per laptop. Opens a browser to sign in to Cloudflare Access;
# after sign-in, returns here and connects. Switch lock / mode / auto-connect
# are enforced by the device profile in the Zero Trust dashboard.
# Usage: ujust warp-enroll <team-name>
[group('Family')]
warp-enroll team:
    #!/usr/bin/env bash
    set -e
    echo "Enrolling device in Cloudflare Zero Trust team: {{ team }}"
    sudo warp-cli teams-enroll "{{ team }}"
    echo
    echo "After completing browser sign-in, connecting WARP..."
    warp-cli connect
    echo
    warp-cli status
