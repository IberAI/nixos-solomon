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

| File                                     | Role                                                                           |
| ---------------------------------------- | ------------------------------------------------------------------------------ |
| `flake.nix`                              | Inputs, formatter, dev shell, `checks`, templates, `nixosConfigurations.nixos` |
| `configuration.nix`                      | Thin wrapper importing `hosts/nixos`                                           |
| `hosts/nixos/default.nix`                | Host entry point: imports every module, sets `system.stateVersion`             |
| `hosts/nixos/hardware-configuration.nix` | Generated per machine, never edited by hand                                    |
| `profiles/native.nix`                    | Chooses which `solomon.*` features are on                                      |
| `modules/profile.nix`                    | Declares every `solomon.*` option                                              |
| `lib/profile.nix`                        | Non-secret shared facts: username, hostname, locale, keyboard, default apps    |
| `home.nix`                               | Home Manager entry point                                                       |
| `Justfile`                               | `just fmt`, `check`, `lint`, `build`, `test`, `switch`                         |

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

Secure Boot through Lanzaboote by default. When
`solomon.boot.secureBoot.enable` is true, the module disables regular
`systemd-boot` with `lib.mkForce false`, enables Lanzaboote, points it at
`/var/lib/sbctl`, and installs `sbctl` for verification and recovery. Override
the option to `false` for unsigned `systemd-boot` with 10 retained generations
and EFI variable access.

- [NixOS bootloader options](https://search.nixos.org/options?query=boot.loader.systemd-boot)
- [Lanzaboote](https://nix-community.github.io/lanzaboote/)
- [Secure Boot guide](secure-boot.md)

### `modules/locale.nix`

Timezone, locale, `LC_*` overrides, and **the keyboard**.

The keyboard is the subtle part. `lib/profile.nix` is the single source, but
three independent consumers need it and no single option feeds all three:

| Consumer                                                         | Option set here                          |
| ---------------------------------------------------------------- | ---------------------------------------- |
| Linux console, including the `greetd`/`tuigreet` password prompt | `console.keyMap`                         |
| X11 clients running under XWayland                               | `services.xserver.xkb`                   |
| sway itself                                                      | _not here_ — see `home/desktop/sway.nix` |

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
- [Repository i2pd guide](networking-i2pd.md)

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
runs the greeter on VT 7 so boot messages remain visible on the boot console
without overwriting the prompt, and starts `greetd.service` as `Type=idle` so
systemd waits for active startup jobs to finish before painting the TUI. It also
registers the fonts and declares the session-wide display-server variables —
`NIXOS_OZONE_WL`, `QT_QPA_PLATFORM`, `SDL_VIDEODRIVER`, and `CLUTTER_BACKEND`.

The Home Manager output configuration explicitly selects a solid color, so
Sway never uses its packaged default wallpaper.

`Super+O` opens `nwg-displays`. Its graphical layout uses Sway's output
management protocol and saves the resulting output positions to the writable
`~/.config/sway/outputs` include. Adjacent output
positions define where the pointer crosses between monitors; scaling is
accounted for by the generated Sway output commands. The launcher passes
`--num_ws 9` to match the nine workspace shortcuts. Workspace assignments are
managed by Nix; `~/.config/sway/workspaces` is deliberately not included, so
old assignments saved by `nwg-displays` cannot override them.

The Sway session launcher passes `--unsupported-gpu`, and the environment
sets `SWAY_UNSUPPORTED_GPU=1`. Both are supported by Sway 1.12. The NVIDIA
driver itself is configured in the NixOS graphics module.

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

fish, `nm-applet` (as a user service — it is deliberately _not_ also launched
from the sway `startup` block), `nix-ld`, the GPG agent, and base CLI packages.

- [nix-ld](https://github.com/nix-community/nix-ld)
- [GnuPG documentation](https://www.gnupg.org/documentation/)

### `modules/streaming/gpu-screen-recorder.nix` — `solomon.streaming.gpuScreenRecorder.enable`

Enables the GPU Screen Recorder NixOS module and its privileged KMS helper,
installs the GTK GUI, and creates a `stream-<name>` command for each configured
target. Keys are read from protected files at runtime. The native profile
currently declares no targets. OBS Studio is not configured.

- [GPU Screen Recorder](https://git.dec05eba.com/gpu-screen-recorder/about/)
- [Repository streaming setup](../README.md#streaming)

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

`stateVersion`, XDG user directories (including `MEDIA`, `PROJECTS`,
`SCREENSHOTS`, `DEVELOPMENT`, `TOOLS`), the base-directory activation script,
and `sessionPath`. `PROJECTS` is intentionally under `~/Development/Projects`;
music, pictures, screenshots, and videos are intentionally under `~/Media`, not
directly under `~`.

### `home/desktop/sway.nix`

The sway **configuration**: keybindings, workspaces, colours, gaps, floating
rules, the `i3status-rust` bar, idle locking, and the keyboard `input`
block.

`home/desktop/sway.nix` imports the focused modules under `home/desktop/sway/`
and keeps session integration and the desktop package list together:

- `appearance.nix`: fonts, gaps, and window colours.
- `windows.nix`: borders, floating rules, focus, and workspace behaviour.
- `workspaces.nix`: workspace-to-monitor assignments and fallback outputs.
- `input-output.nix`: keyboard, background, and writable monitor-layout includes.
- `idle.nix`: the session-bound `services.swayidle` systemd user service.
- `keybindings.nix`: shortcuts and the resize mode.
- `status-bar.nix`: the Sway bar and `i3status-rust` configuration.
- `commands.nix`: shared lock-screen and screenshot command derivations.

Workspaces 1–5 are assigned to the LG ULTRAGEAR on `DP-1`; workspaces 6–9
are assigned to the Philips PHL 242E1GJ on `HDMI-A-1`. Each group lists the
other monitor as a fallback, so workspaces remain accessible if one monitor
is disconnected and return to their preferred monitor when it reconnects.
`Super+1` through `Super+9` select workspaces; adding Shift moves the focused
window to that workspace. Monitor modes, positions, and scaling still come
from `nwg-displays`.

After rebuilding, log out of Sway and log back in to apply the assignments to
a fresh session. Reloading sets the rules for new workspaces but does not
move existing ones. To keep the current session, move each existing workspace
to its assigned output, for example:

```sh
swaymsg 'workspace --no-auto-back-and-forth number 2; move workspace to output DP-1'
```

See the [Sway 1.12 workspace rules](https://github.com/swaywm/sway/blob/1.12/sway/sway.5.scd)
and [Home Manager workspaceOutputAssign option](https://github.com/nix-community/home-manager/blob/release-26.05/modules/services/window-managers/i3-sway/lib/options.nix).

`Super+L` and idle locking use the same lock command. It uses upstream
Swaylock's `--indicator-idle-visible` option; `--indicator` is ambiguous in
upstream Swaylock and causes it to exit before locking. Authentication is supplied
by the NixOS Sway module's PAM service, as described in the
[Home Manager Swaylock options](https://github.com/nix-community/home-manager/blob/release-26.05/modules/programs/swaylock.nix).

The wrapper forwards arguments to Swaylock. Idle locking passes `--daemonize`
with `swayidle -w`, allowing the service to wait until locking completes rather
than waiting until the user unlocks. The service locks after 600 seconds,
before suspend, and on logind lock requests; it does not suspend the machine.
Home Manager restarts the process on failure and binds it to
`sway-session.target`. It is not also launched from Sway's startup block.
See [activation and verification](desktop-idle-and-development.md).

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

### `home/apps/newsboat.nix`

Newsboat with the existing electronics/podcast subscriptions plus Rust Blog,
Inside Rust, This Week in Rust, RustSec, CERT/CC vulnerability notes, and
CIRCL's aggregated known-exploited-vulnerability feed. Tags and three query
feeds separate Rust development, Rust security, and general security reading.
Fetching is hourly, cache vacuuming weekly, and article retention unlimited.
See [feed URLs, coverage, and usage](newsboat.md).

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
