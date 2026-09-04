# Solomon Native NixOS

This branch targets a native NixOS 26.05 system with Home Manager 26.05, Sway,
PipeWire audio, Bluetooth, NVIDIA graphics, and a minimal module set. The
hardware configuration is intentionally left for the target machine.

## Layout

- `flake.nix` defines the `nixos` host output and developer tools.
- `hosts/nixos/` contains host-specific system entry points and hardware.
- `profiles/native.nix` chooses which reusable native features are enabled.
- `modules/` contains reusable NixOS modules.
- `home/` contains Home Manager modules.
- `lib/profile.nix` contains non-secret shared defaults such as username,
  hostname, locale, keyboard layout, private include paths, and default desktop
  applications.
- `scripts/` contains shell scripts that are packaged or read by Nix modules.
- `templates/` contains examples for private files that must not be committed.
- `docs/` contains operational notes and upgrade guides.
- `Justfile` provides shortcuts for manual format, lint, check, build, test,
  and switch commands.

## Documentation

- [Module Reference](docs/module-reference.md) — every module in this
  repository, the `solomon.*` option that switches it on, what it configures,
  and links to the upstream documentation for each component.
- [Upstream Reference Index](docs/upstream-references.md) — documentation links
  for everything this configuration uses, grouped by area.
- [Machine Migration Checklist](docs/machine-migration.md) — what to copy to a
  fresh install, and which paths Home Manager refuses to activate over.
- [NixOS 26.05 Flakes and Home Manager Guide](docs/nixos-flakes-home-manager-26.05.md)
  — the flake workflow, state versions, updating inputs, and debugging.

Two catalogues answer most questions not covered above:

- [NixOS option search](https://search.nixos.org/options)
- [Home Manager option reference](https://nix-community.github.io/home-manager/options.xhtml)

## Project Template

Create a new general development project from this flake:

```sh
nix flake init -t /path/to/nixos-solomon#dev-project
```

The default template is also `dev-project`, so this works too:

```sh
nix flake init -t /path/to/nixos-solomon
```

## Private Identity Files

Git identity, email, signing keys, SSH keys, tokens, and other private values
must stay outside the committed flake.

The Home Manager Git module includes this private file at runtime:

```text
~/.config/git/local.inc
```

Start from:

```text
templates/git-local.inc.example
```

The SSH module includes this private file at runtime:

```text
~/.ssh/config.local
```

Start from:

```text
templates/ssh-config.local.example
```

The SimpleX wrapper reads private SMP connection values at runtime from:

```text
~/.config/simplex/smp.env
```

Start from:

```text
templates/simplex-smp.env.example
```

For real secrets such as tokens, passwords, age keys, private certificates, or
API keys, use a dedicated encrypted secret system such as `sops-nix` or
`agenix`. Ignored local `.nix` files are not a reliable secret mechanism for a
pure Git flake.

## Keyboard

Keyboard configuration is centralized in `lib/profile.nix`.

- Layout: `tr`
- Model: `pc105`
- Variant: empty
- Console keymap: `trq`

Do not add duplicate keyboard definitions unless you intentionally change the
shared profile.

## Native Hardware

The native profile enables:

- PipeWire audio with ALSA, PulseAudio compatibility, JACK, and WirePlumber.
- Bluetooth through BlueZ and Blueman.
- NVIDIA graphics with the open kernel module, modesetting, 32-bit graphics
  support, and the 26.05 `production` driver branch.
- Removable media automounting through the Home Manager `udiskie` user service
  backed by the system `udisks2` service.
- Sway as the native Wayland desktop, with i3-style keybindings,
  `i3status-rust`, Mako, Rofi, `nwg-displays`, Swaylock, Swayidle, Grim/Slurp
  screenshots, Wayland clipboard support, XWayland for X11-only clients, and
  a `greetd`/`tuigreet` login. Press `Super+O` to arrange multiple displays;
  applying the layout saves it for future Sway sessions.
- I2P through `i2pd`, configured as a client-oriented local service with
  localhost-only HTTP proxy, SOCKS proxy, SAM, I2CP, and web console endpoints.
- OBS Studio for recording and streaming, with wlroots/PipeWire capture support,
  per-application PipeWire audio capture, input overlay, vertical canvas, and
  virtual camera support.
- GPU Screen Recorder for low-overhead GPU-encoded capture, instant replay, and
  one-command live streaming. See [Streaming](#streaming).

The pinned Sway 1.12 build accepts NVIDIA without the former
`--unsupported-gpu` option. No undocumented NVIDIA-specific Sway environment
variables are set; driver support is configured through the NixOS NVIDIA and
graphics modules.

For an RTX 5080, keep the NVIDIA driver on a current production/new-feature
branch. If the production branch in your locked Nixpkgs revision is too old for
the card, switch `hardware.nvidia.branch` to `"new_feature"` or update
`nixpkgs` first.

## Streaming

Two tools, deliberately kept side by side:

- **OBS Studio** — the full desk: scenes, overlays, source compositing, an audio
  mixer, and a virtual camera. Its stream URL and key live in
  `Settings -> Stream`.
- **GPU Screen Recorder** — the fast path. Encodes on the GPU with a fraction of
  the overhead, and streams straight to an ingest URL. `gpu-screen-recorder-gtk`
  is the GUI; `programs.gpu-screen-recorder.enable` supplies the setcap wrapper
  that lets KMS capture run without prompting for privileges.

### Declaring a stream destination

Each entry in `solomon.streaming.gpuScreenRecorder.targets` generates a
`stream-<name>` command:

```nix
solomon.streaming.gpuScreenRecorder.targets = {
  twitch = {
    url = "rtmp://live.twitch.tv/app";
    bitrate = 6000;
  };

  youtube = {
    url = "rtmp://a.rtmp.youtube.com/live2";
    audio = ["default_output" "default_input"];
    capture = "portal";
  };
};
```

The stream key is deliberately **not** part of the configuration. Every path in
the Nix store is world readable, so a key committed here would be readable by
every account on the machine and by anyone who reads the repository. It is read
at run time instead, from `keyFile`, which defaults to
`~/.config/gpu-screen-recorder/<name>.key`:

```sh
install -Dm600 /dev/stdin ~/.config/gpu-screen-recorder/twitch.key
# paste the key, then Ctrl-D

stream-twitch
```

The generated script refuses to run if that file is missing or is not mode
`600`/`400`. Extra arguments are forwarded, so `stream-twitch -cursor no` works.

One residual caveat: the recorder takes the ingest URL as an argument and the
key is part of that URL, so it is visible in `/proc/<pid>/cmdline` while the
stream runs. That is fine on a single-user desktop, but do not stream from a
machine that has untrusted local accounts.

Defaults per target are `-w screen`, 60 fps, h264 + AAC in an FLV container, and
constant bitrate — h264/AAC/FLV being what RTMP ingests actually accept. Set
`capture = "portal"` to go through xdg-desktop-portal instead of KMS capture;
the portal session token is then reused so you are not asked to pick an output
on every launch.

## I2P

The native profile enables `services.i2pd` through
`solomon.networking.i2p.enable`.

Local endpoints:

- Router console: `http://127.0.0.1:7070`
- HTTP proxy: `127.0.0.1:4444`
- SOCKS proxy: `127.0.0.1:4447`
- SAM bridge: `127.0.0.1:7656`
- I2CP: `127.0.0.1:7654`

The defaults are intentionally conservative: no UPnP, no floodfill, no published
NTCP2/SSU2 port, no IPv6, no firewall ports opened, and `notransit = true`.
Change those only if you intentionally want this machine to accept inbound I2P
traffic or contribute transit bandwidth.

## Manual Commands

These are intentionally manual:

```sh
nix fmt
nix flake check
just update
just update-switch
sudo nixos-rebuild test --flake .#nixos
sudo nixos-rebuild switch --flake .#nixos
```

`just update` refreshes every flake input and completes all checks plus a full
system build without activating it. Review the resulting `flake.lock` change,
then use `just update-switch` when you want the same pipeline followed by
activation. The desktop uses an explicit solid-color Sway background rather
than the packaged default wallpaper.
