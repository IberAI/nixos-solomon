# Module Reference

Every module in this repository, what it configures, and where the upstream
documentation lives. Options named `solomon.*` are declared in
`modules/profile.nix` and switched on in `profiles/native.nix`.

Two option catalogues are worth keeping open while reading this:

- [NixOS option search](https://search.nixos.org/options) — every `services.*`,
  `programs.*`, `hardware.*` option below
- [Home Manager option reference](https://nix-community.github.io/home-manager/options.xhtml)
  — every option under `home/`

---

## Entry points

| File | Role |
| --- | --- |
| `flake.nix` | Inputs, formatter, dev shell, `checks`, templates, `nixosConfigurations.nixos` |
| `configuration.nix` | Thin wrapper importing `hosts/nixos` |
| `hosts/nixos/default.nix` | Host entry point: imports every module, sets `system.stateVersion` |
| `hosts/nixos/hardware-configuration.nix` | Generated per machine, never edited by hand |
| `profiles/native.nix` | Chooses which `solomon.*` features are on |
| `modules/profile.nix` | Declares every `solomon.*` option |
| `lib/profile.nix` | Non-secret shared facts: username, hostname, locale, keyboard, default apps |
| `home.nix` | Home Manager entry point |
| `Justfile` | `just fmt`, `check`, `lint`, `build`, `test`, `switch` |

Relevant reading: [NixOS modules](https://nixos.org/manual/nixos/stable/#sec-writing-modules),
[flakes](https://wiki.nixos.org/wiki/Flakes), [nix.dev](https://nix.dev/).

---

## System modules

### `modules/nix.nix`

Enables the `nix-command` and `flakes` experimental features, weekly GC with a
10-day retention, weekly store optimisation, and `allowUnfree`.

- [Nix manual](https://nixos.org/manual/nix/stable/)
- [`nix.settings`, `nix.gc`, `nix.optimise`](https://search.nixos.org/options?query=nix.gc)

### `modules/boot.nix`

`systemd-boot` with 10 retained generations and EFI variable access.

- [NixOS bootloader options](https://search.nixos.org/options?query=boot.loader.systemd-boot)

### `modules/locale.nix`

Timezone, locale, `LC_*` overrides, and **the keyboard**.

The keyboard is the subtle part. `lib/profile.nix` is the single source, but
three independent consumers need it and no single option feeds all three:

| Consumer | Option set here |
| --- | --- |
| Linux console, including the `greetd`/`tuigreet` password prompt | `console.keyMap` |
| X11 clients running under XWayland | `services.xserver.xkb` |
| sway itself | *not here* — see `home/desktop/sway.nix` |

Nixpkgs exports no `XKB_DEFAULT_*` variables, so `services.xserver.xkb` never
reaches a Wayland compositor on its own.

- [Keyboard layout customization](https://wiki.nixos.org/wiki/Keyboard_Layout_Customization)
- [`console.keyMap`](https://search.nixos.org/options?query=console.keyMap)

### `modules/networking.nix`

Hostname from the profile, NetworkManager with the OpenConnect plugin, firewall
enabled.

- [NetworkManager documentation](https://networkmanager.dev/docs/)

### `modules/networking/i2p.nix` — `solomon.networking.i2p.enable`

`i2pd` as a client-only router: no transit, no floodfill, no UPnP, unpublished
NTCP2/SSU2, 256 KB/s, localhost-only HTTP proxy, SOCKS, SAM, I2CP and console.

- [i2pd documentation](https://i2pd.readthedocs.io/en/latest/)
- [i2pd source](https://github.com/PurpleI2P/i2pd)

### `modules/audio.nix`

PipeWire with ALSA (plus 32-bit), PulseAudio replacement, JACK, and WirePlumber.
`services.pulseaudio` is explicitly disabled; `security.rtkit` is on so the
audio threads can get real-time priority.

- [PipeWire documentation](https://docs.pipewire.org/)
- [WirePlumber documentation](https://pipewire.pages.freedesktop.org/wireplumber/)
- [PipeWire on the NixOS wiki](https://wiki.nixos.org/wiki/PipeWire)

### `modules/bluetooth.nix` — `solomon.hardware.bluetooth.enable`

BlueZ with `powerOnBoot`, experimental features, Blueman, and the BlueZ CLI
tools.

- [BlueZ](https://github.com/bluez/bluez)
- [Blueman](https://github.com/blueman-project/blueman)
- [Bluetooth on the NixOS wiki](https://wiki.nixos.org/wiki/Bluetooth)

### `modules/graphics/nvidia.nix` — `solomon.hardware.nvidia.enable`

`hardware.graphics` with 32-bit support, the `nvidia` driver selector, the
`production` branch, the open kernel module, KMS modesetting, `nvidia-settings`,
and suspend/resume power management.

`hardware.nvidia.branch` is new in 26.05. Blackwell cards such as the RTX 5080
require `open = true`.

- [NVIDIA on the NixOS wiki](https://wiki.nixos.org/wiki/Nvidia)
- [NVIDIA open kernel modules](https://github.com/NVIDIA/open-gpu-kernel-modules)

### `modules/desktop/sway.nix` — `solomon.desktop.sway.enable`

**Owns the login Sway binary.** Home Manager owns and validates the config
file. Greetd runs `/etc/sway/solomon-session`, which checks that the managed
config exists and passes it to Sway with `--config`; it cannot fall back to an
unrelated system config.

Also sets up the only automatic startup path through `greetd` + `tuigreet`,
registers the fonts, and declares the session-wide display-server
variables — `NIXOS_OZONE_WL`, `QT_QPA_PLATFORM`, `SDL_VIDEODRIVER`,
and `CLUTTER_BACKEND`.

The Home Manager output configuration explicitly selects a solid color, so
Sway never uses its packaged default wallpaper.

`Super+O` opens `nwg-displays`. Its graphical layout uses Sway's output
management protocol and saves the resulting output positions and workspace
assignments to writable include files under `~/.config/sway/`. Adjacent output
positions define where the pointer crosses between monitors; scaling is
accounted for by the generated Sway output commands. The launcher passes
`--num_ws 7` to match the seven workspaces declared by this configuration.

The pinned Sway 1.12 build no longer exposes the former `--unsupported-gpu`
option. NVIDIA support is therefore kept in the NixOS graphics module instead
of relying on undocumented Sway environment variables.

Home Manager's Sway systemd integration derives its D-Bus implementation from
the evaluated NixOS setting. This keeps its activation command compatible with
the system's `dbus-broker` configuration.

Enabling `programs.sway` also implicitly provides `security.polkit`,
`security.pam.services.swaylock`, `xdg.portal.wlr`, the GTK portal, and the
sway portal routing — none of which are repeated in this repository.

- [sway](https://swaywm.org/) · [`sway(5)` config man page](https://man.archlinux.org/man/sway.5)
- [Sway on the NixOS wiki](https://wiki.nixos.org/wiki/Sway)
- [wlroots](https://gitlab.freedesktop.org/wlroots/wlroots)
- [greetd](https://sr.ht/~kennylevinsen/greetd/) · [`greetd(1)`](https://man.archlinux.org/man/greetd.1) · [tuigreet](https://github.com/apognu/tuigreet) · [Greetd on the NixOS wiki](https://wiki.nixos.org/wiki/Greetd)
- [Fonts on the NixOS wiki](https://wiki.nixos.org/wiki/Fonts)

### `modules/portals.nix`

One line: `xdg.portal.enable = true`. Everything else a portals module would
normally declare is already supplied by `programs.sway`.

- [xdg-desktop-portal](https://flatpak.github.io/xdg-desktop-portal/docs/)
- [xdg-desktop-portal-wlr](https://github.com/emersion/xdg-desktop-portal-wlr)

### `modules/services.nix`

`udisks2`, `gvfs`, `upower`, and Tor in client mode with
`AutomapHostsOnResolve` for `.onion` resolution. The SOCKS port backs the
SimpleX wrapper.

- [udisks2 API](https://storaged.org/doc/udisks2-api/latest/)
- [Tor Project](https://community.torproject.org/onion-services/)

### `modules/users.nix` — `solomon.user.enable`

The primary account, with `wheel`, `audio`, `video`, `networkmanager`, `docker`
and `wireshark` groups, and fish as the login shell.

### `modules/security.nix`

`sudo` requiring a password for `wheel`, polkit, and **Wireshark**.

Wireshark is here rather than in `home/` on purpose: the package alone cannot
capture anything. `programs.wireshark` is what creates the `wireshark` group and
the `dumpcap` setcap wrapper (`cap_net_raw,cap_net_admin+eip`). The module
default is `wireshark-cli`, so the GUI is requested explicitly.

- [Wireshark documentation](https://www.wireshark.org/docs/)
- [`programs.wireshark`](https://search.nixos.org/options?query=programs.wireshark)

### `modules/programs.nix`

fish, `nm-applet` (as a user service — it is deliberately *not* also launched
from the sway `startup` block), `nix-ld`, the GPG agent, and base CLI packages.

- [nix-ld](https://github.com/nix-community/nix-ld)
- [GnuPG documentation](https://www.gnupg.org/documentation/)

### `modules/streaming/obs.nix` — `solomon.streaming.obs.enable`

OBS Studio wrapped with `input-overlay`, `obs-pipewire-audio-capture`,
`obs-vertical-canvas`, and `wlrobs`, plus the virtual camera (which pulls in
`v4l2loopback` and its modprobe options automatically).

- [OBS Studio](https://obsproject.com/kb) · [wiki](https://github.com/obsproject/obs-studio/wiki)
- [OBS Studio on the NixOS wiki](https://wiki.nixos.org/wiki/OBS_Studio)
- Plugins: [input-overlay](https://github.com/univrsal/input-overlay) ·
  [obs-pipewire-audio-capture](https://github.com/dimtpap/obs-pipewire-audio-capture) ·
  [obs-vertical-canvas](https://github.com/Aitum/obs-vertical-canvas) ·
  [wlrobs](https://hg.sr.ht/~scoopta/wlrobs)
- [v4l2loopback](https://github.com/umlaeute/v4l2loopback)

### `modules/streaming/gpu-screen-recorder.nix` — `solomon.streaming.gpuScreenRecorder.enable`

Low-overhead GPU-encoded capture and RTMP streaming. The NixOS module is what
provides the `gsr-kms-server` setcap wrapper that KMS capture needs.

Each entry in `.targets` generates a `stream-<name>` command. Stream keys are
read at run time from `keyFile` (mode 600 enforced) and never enter the Nix
store. See [Streaming](../README.md#streaming).

- [GPU Screen Recorder](https://git.dec05eba.com/gpu-screen-recorder/about/)
- [NixOS wiki page](https://wiki.nixos.org/wiki/Gpu-screen-recorder)

### `modules/virtualisation/docker.nix` — `solomon.virtualisation.docker.enable`

Docker pinned to `docker_29`.

- [Docker documentation](https://docs.docker.com/)
- [Docker on the NixOS wiki](https://wiki.nixos.org/wiki/Docker)

### `modules/home-manager.nix` — `solomon.home.enable`

Wires Home Manager as a NixOS module with `useGlobalPkgs`, `useUserPackages`,
and `inputs`/`profile` passed through `extraSpecialArgs`.

- [Home Manager manual](https://nix-community.github.io/home-manager/)
- [Home Manager on the NixOS wiki](https://wiki.nixos.org/wiki/Home_Manager)

---

## Home Manager modules

### `home.nix`

`stateVersion`, XDG user directories (including `SCREENSHOTS`, `DEVELOPMENT`,
`TOOLS`), the base-directory activation script, and `sessionPath`.

### `home/desktop/sway.nix`

The sway **configuration**: keybindings, workspaces, colours, gaps, floating
rules, the `i3status-rust` bar, startup programs, and the keyboard `input`
block.

Home Manager uses the unwrapped `pkgs.sway` to validate the generated config at
build time and reload it after activation. The NixOS-managed wrapper remains
the compositor used at login. Its explicit `--config` argument points to the
Home Manager-owned file, so both halves use the same checked configuration.

- [`sway(5)`](https://man.archlinux.org/man/sway.5)
- [i3status-rust documentation](https://greshake.github.io/i3status-rust/i3status_rs/)
- [Rofi](https://github.com/davatorium/rofi) · [swaylock](https://github.com/swaywm/swaylock) ·
  [grim](https://github.com/emersion/grim) · [slurp](https://github.com/emersion/slurp)

### `home/desktop/notifications.nix`

Mako, themed to match sway, with a `urgency=critical` override.

- [mako](https://github.com/emersion/mako)

### `home/apps/browsers.nix`

Mullvad Browser, and the browser-owned variables `BROWSER`,
`MOZ_ENABLE_WAYLAND`, `MOZ_LEGACY_PROFILES`.

- [Mullvad Browser](https://mullvad.net/en/browser)

### `home/apps/security.nix`

KeePassXC. Wireshark is intentionally absent — see `modules/security.nix`.

- [KeePassXC documentation](https://keepassxc.org/docs/)

### `home/apps/media.nix`, `graphics.nix`, `scientific.nix`, `sioyek.nix`

mpv, GIMP, xnec2c, and the Sioyek PDF viewer.

- [mpv manual](https://mpv.io/manual/stable/) · [GIMP docs](https://www.gimp.org/docs/) ·
  [xnec2c](https://github.com/KJ7LNW/xnec2c) · [Sioyek](https://sioyek.info/)

### `home/apps/simplex/`

A `simplex-chat` CLI built from the upstream release binary with
`autoPatchelfHook`, plus a `simplex-tor` wrapper that reads SMP connection
values from `~/.config/simplex/smp.env` at run time and routes through the Tor
SOCKS proxy. Database lives at `~/.simplex/<profile>`.

- [SimpleX Chat CLI](https://simplex.chat/docs/cli.html) · [source](https://github.com/simplex-chat/simplex-chat)

### `home/dev/kitty.nix`

Kitty, and `TERMINAL`. Uses `FiraCode Nerd Font Mono` — the `Mono` cut matters,
because outside it the patched icon glyphs are roughly one and a half cells wide
and spill into the next column.

- [kitty configuration](https://sw.kovidgoyal.net/kitty/conf/) · [source](https://github.com/kovidgoyal/kitty)
- [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) · [Font Awesome](https://fontawesome.com/docs)

### `home/dev/fish.nix`

Fish: abbreviations, key bindings, functions, colours, `PAGER`/`LESS`. It does
**not** export `EDITOR`, `TERMINAL`, `BROWSER` or the `XDG_*` variables — those
belong to the editor, the terminal, the browser, and `xdg.enable` respectively.

- [fish documentation](https://fishshell.com/docs/current/)

### `home/dev/nvchad.nix`

NvChad via `nix4nvchad`, with LSPs, formatters and linters for Nix, Lua,
TypeScript, Deno, Svelte, shell, Python, Markdown, YAML and TOML. Declares
`EDITOR`/`VISUAL`.

- [NvChad](https://nvchad.com/docs/quickstart/install) · [nix4nvchad](https://github.com/nix-community/nix4nvchad)

### `home/dev/emacs.nix`

`emacs-gtk` with an inline `init.el`, using `JetBrainsMono Nerd Font` from the
`nerd-fonts.jetbrains-mono` package installed in the same file.

- [Emacs manuals](https://www.gnu.org/software/emacs/manual/)

### `home/dev/git.nix`, `ssh.nix`

Git aliases, rebase-only pulls, fast-forward-only merges, `zdiff3` conflicts,
GPG signing; and an SSH client config with agent key-adding and hashed known
hosts. Both include a private file at run time — see
[Private Identity Files](../README.md#private-identity-files).

- [Git reference](https://git-scm.com/docs) · [`ssh_config(5)`](https://man.openbsd.org/ssh_config)

### `home/dev/direnv.nix`, `cli.nix`, `documentation.nix`

direnv with `nix-direnv`, the CLI toolbox, and C/POSIX man and info pages.

- [direnv](https://direnv.net/) · [nix-direnv](https://github.com/nix-community/nix-direnv)
- [Typst documentation](https://typst.app/docs/)

### `home/services/removable-media.nix`

`udiskie` automounting with notifications and no tray icon, restarted on
failure, backed by the system `udisks2` service.

- [udiskie](https://github.com/coldfix/udiskie)

---

## Conventions

1. **One source per fact.** `lib/profile.nix` holds shared values; modules read
   from it rather than repeating literals.
2. **Session variables live with the thing that owns them**, not in a shared
   desktop bucket.
3. **Do not restate what an upstream module already sets.** Duplicated
   definitions merge only while the values stay byte-identical, and fail
   evaluation the moment one side changes.
4. **Secrets never enter the Nix store.** The store is world readable. Use
   run-time files, or [sops-nix](https://github.com/Mic92/sops-nix) /
   [agenix](https://github.com/ryantm/agenix).
5. `nix flake check` must pass, and `alejandra`, `deadnix` and `statix` must be
   clean, before switching.
