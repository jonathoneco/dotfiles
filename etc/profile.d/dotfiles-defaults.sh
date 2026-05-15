#!/bin/sh
# Login-shell defaults. Mirrors etc/environment.d/defaults.conf so values
# reach interactive shells (PAM/profile path) as well as systemd-user
# services (environment.d path).

export EDITOR=nvim
export BROWSER=zen-browser
export HOSTNAME=garden-pad
