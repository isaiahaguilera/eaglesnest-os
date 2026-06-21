# shellcheck shell=bash
###############################################################################
# Override the upstream alias file in-place so our eaglesnest wrapper is the
# canonical entrypoint without relying on filename ordering.
###############################################################################
unalias neofetch 2>/dev/null
unalias neowofetch 2>/dev/null
unalias fastfetch 2>/dev/null

alias neofetch='eaglesnest-fastfetch'
alias neowofetch='eaglesnest-fastfetch'
alias fastfetch='eaglesnest-fastfetch'
