# Upstream Reference Index

Documentation for everything this configuration actually uses. Every link was
checked and returned HTTP 200 at the time of writing.

Two pages answer most day-to-day questions:

- **[NixOS option search](https://search.nixos.org/options)** — any
  `services.*`, `programs.*`, `hardware.*`, `boot.*` option
- **[Home Manager option reference](https://nix-community.github.io/home-manager/options.xhtml)**
  — any option used under `home/`

---

## Nix, NixOS, Home Manager

| Topic | Link |
| --- | --- |
| NixOS manual (stable) | <https://nixos.org/manual/nixos/stable/> |
| NixOS option list | <https://nixos.org/manual/nixos/stable/options> |
| Nixpkgs manual | <https://nixos.org/manual/nixpkgs/stable/> |
| Nix manual | <https://nixos.org/manual/nix/stable/> |
| nix.dev tutorials | <https://nix.dev/> |
| Flakes | <https://wiki.nixos.org/wiki/Flakes> |
| Home Manager manual | <https://nix-community.github.io/home-manager/> |
| Home Manager options | <https://nix-community.github.io/home-manager/options.xhtml> |
| Home Manager source | <https://github.com/nix-community/home-manager> |
| Home Manager (wiki) | <https://wiki.nixos.org/wiki/Home_Manager> |

## Nix tooling

| Tool | Link |
| --- | --- |
| alejandra (formatter) | <https://github.com/kamadorueda/alejandra> |
| deadnix (dead code) | <https://github.com/astro/deadnix> |
| statix (lints) | <https://github.com/oppiliappan/statix> |
| nixd (language server) | <https://github.com/nix-community/nixd> |
| nix-direnv | <https://github.com/nix-community/nix-direnv> |
| direnv | <https://direnv.net/> |

## Desktop — Wayland, sway, session

| Component | Link |
| --- | --- |
| sway | <https://swaywm.org/> |
| `sway(5)` config reference | <https://man.archlinux.org/man/sway.5> |
| Sway on NixOS | <https://wiki.nixos.org/wiki/Sway> |
| wlroots | <https://gitlab.freedesktop.org/wlroots/wlroots> |
| greetd | <https://sr.ht/~kennylevinsen/greetd/> |
| `greetd(1)` | <https://man.archlinux.org/man/greetd.1> |
| tuigreet | <https://github.com/apognu/tuigreet> |
| Greetd on NixOS | <https://wiki.nixos.org/wiki/Greetd> |
| i3status-rust | <https://greshake.github.io/i3status-rust/i3status_rs/> |
| mako notifications | <https://github.com/emersion/mako> |
| Rofi launcher | <https://github.com/davatorium/rofi> |
| swaylock | <https://github.com/swaywm/swaylock> |
| grim screenshots | <https://github.com/emersion/grim> |
| slurp region select | <https://github.com/emersion/slurp> |
| xdg-desktop-portal | <https://flatpak.github.io/xdg-desktop-portal/docs/> |
| xdg-desktop-portal-wlr | <https://github.com/emersion/xdg-desktop-portal-wlr> |
| Keyboard layouts on NixOS | <https://wiki.nixos.org/wiki/Keyboard_Layout_Customization> |
| Fonts on NixOS | <https://wiki.nixos.org/wiki/Fonts> |
| Nerd Fonts | <https://github.com/ryanoasis/nerd-fonts> |
| Font Awesome | <https://fontawesome.com/docs> |

## Graphics and audio

| Component | Link |
| --- | --- |
| NVIDIA on NixOS | <https://wiki.nixos.org/wiki/Nvidia> |
| NVIDIA open kernel modules | <https://github.com/NVIDIA/open-gpu-kernel-modules> |
| PipeWire | <https://docs.pipewire.org/> |
| WirePlumber | <https://pipewire.pages.freedesktop.org/wireplumber/> |
| PipeWire on NixOS | <https://wiki.nixos.org/wiki/PipeWire> |
| PulseAudio (compat layer) | <https://www.freedesktop.org/wiki/Software/PulseAudio/> |

## Streaming and recording

| Component | Link |
| --- | --- |
| OBS Studio knowledge base | <https://obsproject.com/kb> |
| OBS Studio wiki | <https://github.com/obsproject/obs-studio/wiki> |
| OBS on NixOS | <https://wiki.nixos.org/wiki/OBS_Studio> |
| input-overlay | <https://github.com/univrsal/input-overlay> |
| obs-pipewire-audio-capture | <https://github.com/dimtpap/obs-pipewire-audio-capture> |
| obs-vertical-canvas | <https://github.com/Aitum/obs-vertical-canvas> |
| wlrobs | <https://hg.sr.ht/~scoopta/wlrobs> |
| GPU Screen Recorder | <https://git.dec05eba.com/gpu-screen-recorder/about/> |
| GPU Screen Recorder on NixOS | <https://wiki.nixos.org/wiki/Gpu-screen-recorder> |
| v4l2loopback (virtual camera) | <https://github.com/umlaeute/v4l2loopback> |

## Networking, privacy, security

| Component | Link |
| --- | --- |
| NetworkManager | <https://networkmanager.dev/docs/> |
| i2pd | <https://i2pd.readthedocs.io/en/latest/> |
| i2pd source | <https://github.com/PurpleI2P/i2pd> |
| Tor onion services | <https://community.torproject.org/onion-services/> |
| Tor Browser manual | <https://tb-manual.torproject.org/> |
| Mullvad Browser | <https://mullvad.net/en/browser> |
| SimpleX Chat CLI | <https://simplex.chat/docs/cli.html> |
| SimpleX source | <https://github.com/simplex-chat/simplex-chat> |
| Wireshark documentation | <https://www.wireshark.org/docs/> |
| KeePassXC documentation | <https://keepassxc.org/docs/> |
| GnuPG documentation | <https://www.gnupg.org/documentation/> |
| `ssh_config(5)` | <https://man.openbsd.org/ssh_config> |
| sops-nix (secrets) | <https://github.com/Mic92/sops-nix> |
| agenix (secrets) | <https://github.com/ryantm/agenix> |

> `wiki.nixos.org` has no Wireshark or I2P page — both return 404. Use the
> upstream links above together with
> [option search](https://search.nixos.org/options?query=programs.wireshark).

## Shell, editors, terminal

| Component | Link |
| --- | --- |
| fish shell | <https://fishshell.com/docs/current/> |
| kitty configuration | <https://sw.kovidgoyal.net/kitty/conf/> |
| kitty source | <https://github.com/kovidgoyal/kitty> |
| NvChad | <https://nvchad.com/docs/quickstart/install> |
| nix4nvchad | <https://github.com/nix-community/nix4nvchad> |
| Emacs manuals | <https://www.gnu.org/software/emacs/manual/> |
| Git reference | <https://git-scm.com/docs> |
| nix-ld | <https://github.com/nix-community/nix-ld> |

## Hardware, storage, containers

| Component | Link |
| --- | --- |
| BlueZ | <https://github.com/bluez/bluez> |
| Blueman | <https://github.com/blueman-project/blueman> |
| Bluetooth on NixOS | <https://wiki.nixos.org/wiki/Bluetooth> |
| Bluetooth (Arch wiki) | <https://wiki.archlinux.org/title/Bluetooth> |
| udisks2 API | <https://storaged.org/doc/udisks2-api/latest/> |
| udiskie | <https://github.com/coldfix/udiskie> |
| Docker | <https://docs.docker.com/> |
| Docker on NixOS | <https://wiki.nixos.org/wiki/Docker> |
| Linux kernel docs | <https://www.kernel.org/doc/html/latest/> |

## Applications

| Component | Link |
| --- | --- |
| mpv manual | <https://mpv.io/manual/stable/> |
| GIMP documentation | <https://www.gimp.org/docs/> |
| Sioyek PDF viewer | <https://sioyek.info/> |
| xnec2c antenna modelling | <https://github.com/KJ7LNW/xnec2c> |
| Typst | <https://typst.app/docs/> |
