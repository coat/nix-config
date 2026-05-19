---
name: creating-microvm
description: "Creates a new microvm Virtual Machine for running coding agents or dev workloads. Use when the user asks to create, add, or set up a new microvm."
---

# Creating a MicroVM

Create a new ephemeral MicroVM declaration in this NixOS configuration.

`modules/microvm.nix` enumerates every `microvms/*.nix` file and instantiates
each as a guest via `modules/microvm-base.nix`. The filename becomes the VM
name (so `microvms/devvm.nix` → `microvm.vms.devvm`).

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

3. **Optional: project-specific packages.** If extra build tools are wanted,
   add `extraImports` (TODO: not yet wired — for now, edit
   `modules/microvm-base.nix` directly or open an issue).

4. **Create workspace directory and SSH host keys** on the host that owns the
   VM (currently `wopr`):

   ```bash
   mkdir -p ~/microvm/<name>/ssh-host-keys
   ssh-keygen -t ed25519 -N "" -f ~/microvm/<name>/ssh-host-keys/ssh_host_ed25519_key
   ```

5. **Verify** the configuration evaluates:

   ```bash
   nix eval --no-write-lock-file \
     'path:.#nixosConfigurations.wopr.config.microvm.vms.<name>vm.config.config.system.stateVersion'
   ```

6. **Format** with `nix fmt`.

7. **Report back** with:
   - VM name and IP address
   - How to start: `sudo systemctl start microvm@<name>vm`
   - How to SSH: `ssh sadbeast@192.168.83.X`
   - Workspace path inside VM: `~/workspace`

## Key Files

- `microvms/<name>vm.nix` — per-VM args record.
- `modules/microvm.nix` — host bridge network + `microvm.vms` enumeration.
- `modules/microvm-base.nix` — base guest config function (network, shares, home-manager).
- `lib/ssh-keys.nix` — SSH authorized keys.
