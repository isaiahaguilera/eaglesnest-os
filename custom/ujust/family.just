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
