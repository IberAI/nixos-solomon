# Secure Boot With Lanzaboote

This repository supports two boot modes from the same configuration:

- Default mode: Lanzaboote, for machines where local Secure Boot keys have
  been generated and enrolled.
- Unsigned mode: regular `systemd-boot`, for recovery or machines with Secure
  Boot disabled.

The default is Secure Boot mode:

```nix
solomon.boot.secureBoot.enable = true;
```

Set it to `false` while initially installing on an unprovisioned machine, or
when recovering with Secure Boot disabled in firmware.

## How Secure Boot Trust Works

Secure Boot is enforced by UEFI firmware before the operating system starts. The
firmware validates EFI programs against its Secure Boot databases:

- `PK`: platform key, controls whether the machine is in user mode or setup mode.
- `KEK`: key exchange keys, authorized to update the allow and deny databases.
- `db`: allowed signatures and hashes.
- `dbx`: forbidden signatures and hashes.

Windows normally boots because the Windows boot chain is signed by Microsoft and
consumer firmware usually trusts Microsoft keys. NixOS needs a trusted Linux boot
chain too. Lanzaboote handles this by replacing the normal systemd-boot install
path and signing the NixOS boot artifacts with keys managed by `sbctl`.

On a two-SSD system with Windows on one disk and NixOS on another, each disk can
keep its own EFI System Partition. The firmware boot menu can still select either
disk. Secure Boot trust is firmware-wide, so Windows keeps working only if the
firmware still trusts the Microsoft signing chain.

## Repository Configuration

The Lanzaboote flake input is pinned in `flake.nix`:

```nix
lanzaboote = {
  url = "github:nix-community/lanzaboote/v1.1.0";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

The host imports `inputs.lanzaboote.nixosModules.lanzaboote`, and the native
profile enables `solomon.boot.secureBoot.enable` by default.

When Secure Boot is disabled by override, `modules/boot.nix` enables regular
systemd-boot:

```nix
boot.loader.systemd-boot.enable = true;
boot.loader.systemd-boot.configurationLimit = 10;
boot.loader.efi.canTouchEfiVariables = true;
```

When Secure Boot is enabled, the same module disables the normal systemd-boot
module and enables Lanzaboote:

```nix
boot.loader.systemd-boot.enable = lib.mkForce false;

boot.lanzaboote = {
  enable = true;
  pkiBundle = config.solomon.boot.secureBoot.pkiBundle;
};
```

`sbctl` is installed only in Secure Boot mode. The default key directory is:

```nix
solomon.boot.secureBoot.pkiBundle = "/var/lib/sbctl";
```

Never commit `/var/lib/sbctl`. It contains private signing keys.

## Preflight Before Rebuild

Because Secure Boot mode is the default in this repository, prepare the target
machine before running `nixos-rebuild switch` with this configuration.

Check that the existing system is a UEFI system using systemd-boot:

```sh
sudo bootctl status
```

The Lanzaboote setup guide expects firmware mode to be UEFI and the current boot
loader to be systemd-boot before switching to Lanzaboote.

Back up the Windows BitLocker or device-encryption recovery key before changing
firmware Secure Boot state or enrolling keys.

Check the NixOS EFI System Partition has enough room for signed generations:

```sh
df -h /boot
sudo find /boot/EFI -maxdepth 2 -type f | wc -l
```

This repository keeps 10 boot generations. Lanzaboote copies signed boot
artifacts to the ESP, so a small or full ESP can break bootloader installation.

Create local signing keys before the first rebuild with this default:

```sh
nix shell nixpkgs#sbctl
sudo sbctl create-keys
sudo sbctl status
```

Confirm the key directory exists and keep it private:

```sh
sudo test -d /var/lib/sbctl
sudo ls -la /var/lib/sbctl
```

Only after those checks should you evaluate, build, and test the system:

```sh
nix flake check
sudo nixos-rebuild test --flake .#nixos
```

If this machine is not provisioned yet, temporarily override Secure Boot mode to
false and rebuild unsigned systemd-boot first:

```nix
solomon.boot.secureBoot.enable = false;
```

## Enable Firmware Enforcement

The repository default is already enabled:

```nix
solomon.boot.secureBoot.enable = true;
```

After the preflight checks, activate the signed boot configuration:

```sh
nix flake check
sudo nixos-rebuild switch --flake .#nixos
sudo sbctl verify
```

The Lanzaboote docs note that unsigned kernel files under `/boot/EFI/nixos` can
still appear in `sbctl verify`; the signed generation stubs under
`/boot/EFI/Linux/` are the important boot entries.

Put the firmware into Secure Boot setup mode, then boot back into NixOS and
enroll local keys plus Microsoft keys:

```sh
sudo sbctl enroll-keys --microsoft
```

Use Microsoft keys on this dual-boot machine. They keep Windows bootable and can
also be needed for firmware Option ROMs. On hardware that requires vendor keys
for firmware updates, add the firmware built-in keys too:

```sh
sudo sbctl enroll-keys --microsoft --firmware-builtin
```

Reboot, enable Secure Boot enforcement in firmware if your firmware did not do it
automatically, and verify:

```sh
bootctl status
sudo sbctl status
sudo sbctl verify
```

Expected result: `bootctl status` reports Secure Boot enabled in user mode, and
both firmware boot entries still work: the Windows SSD and the NixOS SSD.

## Disable Or Recover

To return this repository to unsigned boot:

```nix
solomon.boot.secureBoot.enable = false;
```

Then rebuild with Secure Boot disabled in firmware:

```sh
sudo nixos-rebuild switch --flake .#nixos
```

If a signed NixOS generation fails before the kernel starts, disable Secure Boot
in firmware and boot an older generation or a NixOS installer. Lanzaboote's
troubleshooting guide recommends reinstalling the boot artifacts with
`nixos-rebuild boot` after repairing or cleaning the ESP.

If Windows uses BitLocker or device encryption, back up the recovery key before
changing firmware Secure Boot state or enrolling keys. Firmware trust changes can
alter measured boot state and trigger Windows recovery.

## Sources

- UEFI Secure Boot specification:
  <https://uefi.org/specs/UEFI/2.10/32_Secure_Boot_and_Driver_Signing.html>
- Microsoft Secure Boot and Trusted Boot:
  <https://learn.microsoft.com/en-us/windows/security/operating-system-security/system-security/trusted-boot>
- Microsoft BitLocker configuration:
  <https://learn.microsoft.com/en-us/windows/security/operating-system-security/data-protection/bitlocker/configure>
- Lanzaboote documentation:
  <https://nix-community.github.io/lanzaboote/>
- Lanzaboote setup guide:
  <https://nix-community.github.io/lanzaboote/getting-started/prepare-your-system.html>
- Lanzaboote key enrollment guide:
  <https://nix-community.github.io/lanzaboote/getting-started/enable-secure-boot.html>
- Lanzaboote automatic enrollment notes:
  <https://nix-community.github.io/lanzaboote/how-to-guides/automatically-enroll-keys.html>
- systemd-boot documentation:
  <https://systemd.io/BOOT/>
