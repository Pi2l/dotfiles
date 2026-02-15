cd ~/.dotfiles/.config/
stow -vRt ~/.config/wallust wallust

# Deps
## pacman:
```
sudo pacman -S waybar hypridle hyprlock xdg-desktop-portal-hyprland btop hyprsunset nautilus wofi kitty tlp hyprpaper wl-clipboard cliphist pipewire pipewire-pulse file-roller eza bat fzf starship jq bc nwg-look xdg-desktop-portal-hyprland swaync brightnessctl libnotify swayosd-libinput-backend swayosd hyprshot hyprpolkitagent
```

## AUR
```
yay -S wlogout wallust pwvucontrol hyprland-per-window-layout
```

## Fonts
Noto, Jetbrains, Adwaita mono
```
sudo pacman -S noto-fonts noto-fonts-cjk adwaita-fonts ttf-nerd-fonts-symbols noto-fonts-emoji
```

## Polkit and [fingerprint auth](https://wiki.archlinux.org/title/Fprint)
1. Install [hyprpolkitagent](https://wiki.hypr.land/Hypr-Ecosystem/hyprpolkitagent/)
2. Install fprintd package
3. Add `/etc/pam.d/system-local-login`:
```
auth        sufficient 	pam_unix.so try_first_pass likeauth nullok # or remove this line if you want use fingerprint first and not to press enter to use it
auth        sufficient	pam_fprintd.so
```
4. Create fingerprint signature (`fprintd-verify` to verify):
```
fprintd-enroll
```
5. Restrict enrolling to only users in `wheel` group (create/edit `/etc/polkit-1/rules.d/50-net.reactivated.fprint.device.enroll.rules`):
```
polkit.addRule(function(action, subject) {
    if (action.id == "net.reactivated.fprint.device.enroll") {
        return subject.isInGroup("wheel") ? polkit.Result.YES : polkit.Result.NO;
    }
});
```
6. Restart polkit: `sudo systemctl restart polkit`

Tlp:
USB_EXCLUDE_PHONE=1

