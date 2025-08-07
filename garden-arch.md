# The Garden Arch

Look, this all feels a little bit like overkill, but I was thinking about it and all this tech stuff used to feel like magic. Then I learned more about it and developed a sense for how things worked, and it kinda stopped feeling that way, and I just let that disillusionment prevail. Today I realize, it is magic, and I am best served by learning how to cast spells.

Shadow Wizard Money Gang, We Love Casting Spells

## Stack
- Desktop Environment:
    - Display Manager: ly
    - Window Manager: wayland
    - Compositor: hyprland
    - Status Bar: waybar
    - Notification Daemon: swaync
    - Screenshot Tool: hyprshot
    - File Browser: nautilus / ranger
    - Thumbnailer: tumbler
    - Fonts: fontconfig
    - Email Browser: thunderbird
    - Wallpapers: hyprpaper
    - Idle: hypridle
    - Lock: hyprlock
    - Blue Light Filter: hyprsunset
    - Auth: hyprpolkitagent
    - System Info: hyprsysteminfo
    - Cursor: hyprcursor
- System
    - Power Management
        - tlp
        - powertop
        - tlpui
- Development Tools:
    - Terminal: zsh
    - Text Editor: nvim
    - Tmux: tmux

## Upgrade Considerations
- Hard Drive: I encrypted my harddrive and am using timeshift for snapshots
- Memory: I installed and configured zram

---

# Bootstrapping
- make directories
    - src/
    - src/dotfiles
    - src/scratch
    - .config
- clone repo
- make config/tmux/plugins/tpm
- install dependencies
- stow configs
- install fonts
    - system font install
- install oh-my-zsh
- install wallpapers
- use pnpm to install node
    - pnpm env use --global lts
- login to github-cli
- setup secure boot


# NOTES
- Change power button to hibernate
- configure fingerprint reader
    - may need to switch from ly to something else
- setup script to login to tailscale

- setup dependency installer
    - installs plugins
        - git clone https://github.com/cdump/ranger-devicons2 /config/ranger/plugins/devicons2

## OpenCode
- setup Beast Mode

## Themeing
- Fix gtk themeing

- Clean up Waybar configs

- Make wallpaper selector preview the highlighted selection

- Auto light mode depending on background

- Once I've got rose-pine setup, going to setup the rest of my system. After, I want to setup a modular theme that updates everything at once with scripts, then get things like catpuccin, gruvbox, nord, tokyonight, katagawa, etc.
- Maybe, use real hardcoded themes, and switcher uses random wallpapers that work with those themes

### Matugen TODO
- zen-browser
- zed
- nvim
- thunderbird
- nautilus


## System
- zsh history inconsistency
    - ctrl-r doesn't caputre everything
- system maintenance
    - research
    - update and upgrade
    - clear orphaned packages
    - parse package list for apps I installed but won't use
- monitor scripts
    - since using wayland, monitor configs should be part of the hyprland config
    - going to have a layout.conf sourced from the config, and have a script swap out a symlink to that file depending on the layout I want to use
    - write a bash script watching socket2 for display events
    - https://wiki.hypr.land/IPC/

## Security Hardening
- BIOS supervisor password
- restrict access to grub files / make them immutable
- disable recover and osprober
- setup grub password

## Server
- Remove deprecated ssh key
- Add current ssh key
- self host start page?
- move tailscale off docker container to instead run directly on server so I don't run into rec issues
- use script that gets run on startup to login to tailscale
- use arch dotfiles (hopefully works with debian out of the box)


## Hyprland
- turning off animations, might want to turn them back on later
- update ly to get colormix to match rose-pine
- setup wallpapers
- if I start running into issues with the top end of my brightness, I can turn on keymaps for hyprsunset gamma
- Put hyprsunset on a timer

## ZSH

## NVIM
- latex not working
- install ai into cmp

## Eventually
- system maintenance research
    - refresh mirrorlist and package database
        - sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
        - sudo pacman -Syy
- Note Taking System
- Might want to swap to sddm
- Scheduled maintenance every three months
    - run system-maintenance
    - Notes for desired config changes
    - every 90 days need to replace garden-bed's tailscale auth key

## Fun
- I want to setup the ascii generator thing primeagen uses
    - need to re-add "image-generator" to tmux-sessionizer conf
    - need to look at the localhost server he has running

## Garden Bed
- Fix deployment scripts
- centralize script environment variable configs

## Notion
- Notion Replacement
- dmenu for fzf

# References
https://github.com/ThePrimeagen/dev
https://github.com/binnewbs/arch-hyprland
https://github.com/paulalden/dotfiles/tree/main

[!WARNING]
test
