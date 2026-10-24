# Newsboat: Rust Development and Security Feeds

`home/apps/newsboat.nix` configures Newsboat, the terminal RSS/Atom reader.
It remains imported by `home/apps/default.nix`. The existing electronics,
embedded-systems, and Casey Muratori subscriptions are retained.

## New subscriptions

| Feed | Purpose | URL |
| --- | --- | --- |
| Rust Blog | Official releases and major project announcements, including security announcements | <https://blog.rust-lang.org/feed.xml> |
| Inside Rust | Compiler, language, library, and tooling-team development | <https://blog.rust-lang.org/inside-rust/feed.xml> |
| This Week in Rust | Weekly community news, learning material, and ecosystem updates | <https://this-week-in-rust.org/atom.xml> |
| RustSec Advisories | Rust dependency advisories; some advisories have CVE aliases | <https://rustsec.org/feed.xml> |
| CERT/CC Vulnerability Notes | Coordinated disclosures, affected vendors, and remediation details | <https://kb.cert.org/vulfeed/> |
| CIRCL Known Exploited Vulnerabilities | Recent exploitation-status updates aggregated across known KEV catalogs | <https://vulnerability.circl.lu/kev-catalogs/feed.atom> |

All six new URLs were fetched and parsed as non-empty RSS/Atom feeds on
2026-10-24. Feed availability and publication schedules can change.

The CIRCL feed is an aggregation, not a direct CISA feed. Entries identify
their originating catalog; the same CVE can appear from multiple catalogs.
It contains recent updates, not a complete vulnerability history.

These feeds provide news and advisory awareness, not a scan of this machine
or your projects. A RustSec advisory need not have a CVE and may describe an
unmaintained or otherwise unsound crate. Use project dependency auditing to
determine whether an advisory affects a particular `Cargo.lock`.

## Reading and organization

After the next NixOS rebuild, restart Newsboat:

```sh
newsboat
```

Three query feeds group articles without fetching duplicate subscriptions:

- **Rust development**: Rust Blog, Inside Rust, and This Week in Rust.
- **Rust security**: RustSec advisories.
- **Security advisories**: RustSec, CERT/CC, and CIRCL KEV updates.

Press `T` to filter subscriptions by tags such as `rust`, `security`, `cve`,
or `exploited`; `Ctrl+T` clears the tag filter. Press `R` to reload all feeds
immediately. Press `o` on an article to open it in the configured browser.
The existing `p` macro remains available through the macro prefix `,` followed
by `p`, opening the selected article in mpv.

The existing background policy is unchanged: fetch hourly, vacuum weekly,
and retain unlimited articles. This updates the local reader cache; it does
not send desktop notifications. The timers run through the user's systemd
manager. Check or trigger fetching with:

```sh
systemctl --user status newsboat-fetch-articles.timer
systemctl --user start newsboat-fetch-articles.service
journalctl --user -u newsboat-fetch-articles.service -b
```

Home Manager owns `~/.config/newsboat/config` and `~/.config/newsboat/urls`.
Edit the Nix module rather than these generated files.

## Source documentation

- [Rust Blog](https://blog.rust-lang.org/)
- [RustSec](https://rustsec.org/)
- [This Week in Rust](https://this-week-in-rust.org/)
- [CERT/CC Vulnerability Notes](https://kb.cert.org/vuls/)
- [CIRCL feed semantics](https://www.vulnerability-lookup.org/documentation/feeds.html)
- [Newsboat tags and query feeds](https://newsboat.org/releases/2.40/docs/newsboat.html)
