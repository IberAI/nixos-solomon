# I2P With i2pd

This repository enables a local, client-oriented I2P router through `i2pd`:

```nix
solomon.networking.i2p.enable = true;
```

The module lives at `modules/networking/i2p.nix`.

## What Is Enabled

The router is configured for local application use, not public relay service:

- IPv4 enabled, IPv6 disabled.
- No transit traffic: `notransit = true`.
- No floodfill role.
- No UPnP.
- NTCP2 and SSU2 enabled but not published.
- No firewall ports opened for inbound I2P traffic.
- Bandwidth capped at `256` KB/s.

State lives under:

```text
/var/lib/i2pd/
```

Copying that directory during migration preserves the router identity. Skipping
it is also acceptable; i2pd will create a new identity.

## Local Endpoints

All exposed services bind to localhost:

| Purpose | Address |
| --- | --- |
| Router console | `http://127.0.0.1:7070` |
| HTTP proxy | `127.0.0.1:4444` |
| SOCKS proxy | `127.0.0.1:4447` |
| SAM bridge | `127.0.0.1:7656` |
| I2CP | `127.0.0.1:7654` |

Use the HTTP proxy for normal `.i2p` browsing. Use SOCKS only for software that
explicitly supports SOCKS proxying for its protocol.

## Browser Use

Configure a browser profile or extension with:

```text
HTTP proxy: 127.0.0.1
HTTP port: 4444
HTTPS proxy: 127.0.0.1
HTTPS port: 4444
```

Then open:

```text
http://127.0.0.1:7070
```

The router needs time to build tunnels after service start. If `.i2p` sites fail
immediately after boot, wait a few minutes and check the router console.

## Service Commands

Inspect the service:

```sh
systemctl status i2pd
journalctl -u i2pd -b
```

Restart it after changing configuration:

```sh
sudo systemctl restart i2pd
```

Check local listening sockets:

```sh
ss -ltnp | grep i2pd
```

## When To Open Ports

Do not open firewall ports for the current workstation profile. The current
configuration is intentionally private and client-only.

Only change `ntcp2.published`, `ssu2.published`, fixed ports, and firewall rules
if this machine should accept inbound I2P traffic or contribute more router
capacity. That is a different operating mode and should be documented with the
exact ports and bandwidth policy.

## Sources

- i2pd documentation: <https://i2pd.readthedocs.io/en/latest/>
- i2pd source: <https://github.com/PurpleI2P/i2pd>
- NixOS option search: <https://search.nixos.org/options>
