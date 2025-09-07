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

## Bootstrapping

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

---

## References

https://github.com/ThePrimeagen/dev
https://github.com/binnewbs/arch-hyprland
https://github.com/paulalden/dotfiles/tree/main
