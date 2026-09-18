---
name: creating-microvm
description: "Creates a new microvm Virtual Machine for running coding agents or dev workloads. Use when the user asks to create, add, or set up a new microvm."
---

# Creating a MicroVM

Create a new ephemeral MicroVM declaration in this NixOS configuration.

`modules/microvm.nix` enumerates every `microvms/*.nix` file and instantiates
each as a guest via `modules/microvm-base.nix`. The filename becomes the VM
name (so `microvms/devvm.nix` → `microvm.vms.devvm`). The module is imported
by `modules/desktop-host.nix`, so every desktop-profile host (currently
`joshua`, `wopr`) can run any VM; nothing is tied to one host.

## Steps

1. **Pick free network/vsock IDs.** Read existing files in `microvms/` to
   find IPs, tapIds, MAC addresses, and vsockCids already in use, then choose
   the next free values:
   - IP: `192.168.83.X/24` (start from .2, increment)
   - tapId: `microvmN` (start from 0, increment)
   - MAC: `02:00:00:00:00:XX` (start from 01, increment hex)
   - vsockCid: integer (start from 3, increment; 0–2 are reserved)

2. **Create `microvms/<name>vm.nix`** with the per-VM args:

   ```nix
   {
     ipAddress = "192.168.83.X/24";
     tapId = "microvmN";
     mac = "02:00:00:00:00:XX";
     workspace = "/home/sadbeast/microvm/<name>";
     vsockCid = N;
   }
   ```

   The filename (without `.nix`) becomes the hostname and the
   `microvm.vms.<name>` key — no separate registration needed.

   Optional attrs (see `microvms/pairvm.nix` for an example):
   - `user` — guest login user (default `sadbeast`). Needs
     `users/<user>/home.nix` and a `sshKeys.<user>` list in
     `lib/ssh-keys.nix`, unless `authorizedKeys` / `homeImports` are given.
   - `authorizedKeys` — SSH keys for that user (default `sshKeys.<user>`).
   - `homeImports` — HM modules (default `users/<user>/home.nix` +
     `users/features/dev.nix`).
   - `sshProxyPort` — host-side `systemd-socket-proxyd` listener on that
     port forwarding to the guest's sshd, plus a firewall opening. Use when
     someone outside the host needs to SSH into the VM.

3. **Optional: project-specific packages.** Pass `homeImports` with extra
   feature modules, or edit `modules/microvm-base.nix` for guest-wide changes.

4. **Verify** the configuration evaluates on a desktop host:

   ```bash
   nix eval --no-write-lock-file \
     'path:.#nixosConfigurations.joshua.config.microvm.vms.<name>vm.config.config.system.stateVersion'
   ```

5. **Format** with `nix fmt`.

6. **Report back** with:
   - VM name and IP address
   - How to deploy: `clan machines update <host>` (or `sudo nixos-rebuild switch --flake .#<host>`)
   - How to start: `sudo systemctl start microvm@<name>vm`
   - How to SSH: `ssh <user>@192.168.83.X` (or `ssh -p <sshProxyPort> <user>@<host>` from off-host)
   - Workspace path inside VM: `~/workspace`

No manual host prep is needed: `microvm-virtiofsd@<name>` creates the workspace dir as
uid 1000 before start, and the guest's SSH host key is generated on first boot
into the persistent `/var` volume.

## Key Files

- `microvms/<name>vm.nix` — per-VM args record.
- `modules/microvm.nix` — host bridge network, workspace prep, SSH proxies, `microvm.vms` enumeration.
- `modules/microvm-base.nix` — base guest config function (network, shares, user, home-manager).
- `lib/ssh-keys.nix` — SSH authorized keys.
