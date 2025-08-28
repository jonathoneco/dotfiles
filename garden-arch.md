# The Garden Arch

Look, this all feels a little bit like overkill, but I was thinking about it and all this tech stuff used to feel like magic. Then I learned more about it and developed a sense for how things worked, and it kinda stopped feeling that way, and I just let that disillusionment prevail. Today I realize, it is magic, and I am best served by learning how to cast spells.

Shadow Wizard Money Gang, We Love Casting Spells

## Hardware
- Dell Latitude 5440

## Stack
- Desktop Environment:
    - Display Manager: sddm
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
- make directories (all at ~/)
    - src/
    - src/dotfiles
    - src/scratch
    - .config
    - .local/bin
    - .local/var
    - .local/var/log
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
- Update logind conf to set the power button to sleep
```
HandlePowerKey=suspend
HandlePowerKeyLongPress=poweroff
```
- add `auth sufficient pam_fprintd.so` to `/etc/pam.d/sddm`, `/etc/pam.d/sudo` and `/etc/pam.d/polkit-1`

- Install go docs
`go install golang.org/x/tools/cmd/godoc@latest`

- Install udev rule for keymapp (for flashing keyboard)
`https://github.com/zsa/wally/wiki/Linux-install`



# NOTES

- split up dependencies in deps/arch
- Create a script that builds the patched dmenu, and installs it

- Enable suspend then hibernate

- Use VNC server to use ipad as second monitor
- Setup DAP for golang

- make timezone internet region dependent (update with travel)

## SDDM
- Theme to match desktop
- Use current wallpaper

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

## Rofi
- Scenario specific configs for
    - Main
    - Wallpaper Picker
    - Cliphist
    - Garden-Logger

## System
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
- Context grabbing keybinds
    - yanking diagnostic and context information (like <leader>yd or smth)
    - yanking current method and relative filepath
- Add Search Count
- Need to fix spellcheck to only work in relevant files
    - I keep seeing them in golang and other programming files

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
- Look at Omarchy for certain quality of life features
    - scripts for things like installing web-apps
    - unified menu
    - theme switcher
- setup palm rejection for touch pad
    - I've configured the touchpad setting but it seems hyprland is recognizing my touchpad as a mouse
- setup dependency installer
    - installs plugins
        - git clone https://github.com/cdump/ranger-devicons2 /config/ranger/plugins/devicons2

## Fun
- I want to setup the ascii generator thing primeagen uses
    - need to re-add "image-generator" to tmux-sessionizer conf
    - need to look at the localhost server he has running

## TMUX
- Add scripts and shortcuts for
    - clearing a session
        - wqa out of nvim
        - close all shells
        - keep one fresh pan open
    - gracefully close session
        - Jumps to last or closest available open session
    - env setup
        1. nvim at root
        2. shell
        3. opencode

## Garden Bed
- Fix deployment scripts
- centralize script environment variable configs

## Garden Log
- Notion Replacement
- Migrate Notion
- Indexing tools
- Figure out obsidian syncing
- move over dev logs from this and garden-bed
- dmenu for fzf
- setup dmenu option for New From Template
- support for creating directories
- support for renaming a folder and it's subfolders
- vim binds
- Right now, when a note is open it shows up in the window switcher as nvim, if I can get it to show the note name that'd make searching nicer

## cliphist dmenu
- not working

# References
https://github.com/ThePrimeagen/dev
https://github.com/binnewbs/arch-hyprland
https://github.com/paulalden/dotfiles/tree/main

[!WARNING]

