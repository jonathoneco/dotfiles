# Notes

Look, this all feels a little bit like overkill, but I was thinking about it and all this tech stuff used to feel like magic. Then I learned more about it and developed a sense for how things worked, and it kinda stopped feeling that way, and I just let that disillusionment prevail. Today I realize, it is magic, and I am best served by learning how to cast spells.

Shadow Wizard Money Gang, We Love Casting Spells

## Stack
- Desktop Environment:
    - Display Manager: ly
    - Window Manager: wayland
    - Compositor: hyprland
    - Status Bar: waybar
    - Notification Daemon: mako
    - Screenshot Tool: hyprshot
    - File Browser: dolphin / yazi
    - Thumbnailer: tumbler
    - Fonts: fontconfig (ghostty uses firacode nerd font)
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

# NOTES

- Change power button to hibernate
- setup dependency installer
    - installs plugins
        - git clone https://github.com/cdump/ranger-devicons2 /config/ranger/plugins/devicons2
- configure opencode
- configure fingerprint reader
    - may need to switch from ly to something else

## OpenCode
- Give LLM info about system tools and available packages

## LF
- Doesn't currently support opening links
- Preview looks fine in kitty but not in ghostty, might just swtich to kitty

## Themeing
- working
    - tmux
    - nvim
    - btop
    - rofi
    - spotify
    - zed
    - ghostty
    - zen-browser

- not working
    - hyrpcursor
    - icons (dolphin)
    - fzf
    - ly

- config waybar

- Once I've got rose-pine setup, going to setup the rest of my system. After, I want to setup a modular theme that updates everything at once with scripts, then get things like catpuccin, gruvbox, nord, tokyonight, katagawa, etc.
- I also want to support transparency

## System
- setup display scripts
    - write a bash script watching socket2 for display events
    - https://wiki.hypr.land/IPC/
- zsh history inconsistency
    - ctrl-r doesn't caputre everything
- system maintenance
    - research
    - update and upgrade
    - clear orphaned packages
- get themeing all synced up
- parse package list for apps I installed but won't use
- checkout graphite git tool

- monitor scripts
    - since using wayland, monitor configs should be part of the hyprland config
    - going to have a layout.conf sourced from the config, and have a script swap out a symlink to that file depending on the layout I want to use

## Matugen
- zen-browser
- zed
- nvim
- tmux
- fzf
- thunderbird
- nautilus
-

## FZF
- Use <C- > vim binds for search parsing

## Security Hardening
- BIOS supervisor password
- restrict access to grub files / make them immutable
- disable recover and osprober
- setup grub password

## Server
- Remove deprecated ssh key
- Add current ssh key
- self host start page?

## Waybar
- Fix spacing
- Add brightness module

## Hyprland
- turning off animations, might want to turn them back on later
- update ly to get colormix to match rose-pine
- setup wallpapers
- if I start running into issues with the top end of my brightness, I can turn on keymaps for hyprsunset gamma

## ZSH

## NVIM
- turn off supermaven autocomplete, swap for completions
- add descriptiosn to nvim keymaps
- fix nvim theming
- swap netrw for some other shit
- latex not working
- markdown not working
- re-add telescope search navigation with C-j and C-k
- revert comment extension
- search open buffers
- switch to other buffer remap as it currently overlaps with breakpoint
- fix nvim comment extension
- install ai into cmp
- use grep search as location list

## Eventually
- s3sleep or whatever it's called
- system maintenance research
    - refresh mirrorlist and package database
        - sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
        - sudo pacman -Syy
- Note Taking System
- Might want to swap to sddm

## TMUX
- Set default tmux session

## Fun
- I want to setup the ascii generator thing primeagen uses
    - need to re-add "image-generator" to tmux-sessionizer conf
    - need to look at the localhost server he has running

## Wallpapers
- Setup nice wallpaper switcher
- Remove hyprpaper scripts if matugen works

## Yazi
- configure
- Look into plugins
    - One for vi like marks


# References
https://github.com/ThePrimeagen/dev
https://github.com/binnewbs/arch-hyprland
https://github.com/paulalden/dotfiles/tree/main
