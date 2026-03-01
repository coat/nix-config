---
name: creating-microvm
description: "Creates a new microvm Virtual Machine for running coding agents or dev workloads. Use when the user asks to create, add, or set up a new microvm."
---

# Creating a MicroVM

Create a new ephemeral MicroVM declaration in this NixOS configuration.

## Steps

1. **Read existing VMs** in `modules/microvm.nix` to find used IP addresses, tapIds, and MAC addresses. Choose the next free values:
   - IP: `192.168.83.X/24` (start from .2, increment)
   - tapId: `microvmN` (start from 0, increment)
   - MAC: `02:00:00:00:00:XX` (start from 01, increment hex)

2. **Add a new `microvm.vms.<name>vm` entry** in `modules/microvm.nix` following the existing pattern:

   ```nix
   microvm.vms.<name>vm = {
     autostart = false;
     config = {
       imports = [
         inputs.microvm.nixosModules.microvm
         (microvmBase {
           hostName = "<name>vm";
           ipAddress = "192.168.83.X/24";
           tapId = "microvmN";
           mac = "02:00:00:00:00:XX";
           workspace = "/home/sadbeast/microvm/<name>";
           inherit inputs outputs homeManagerSharedModules;
         })
       ];
     };
   };
   ```

3. **Add project-specific packages** (optional). If the user requests specific build tools or language runtimes, add them as `environment.systemPackages` in a new file at `microvms/<name>.nix` and include it in the VM's imports:

   ```nix
   # microvms/<name>.nix
   {pkgs, ...}: {
     environment.systemPackages = with pkgs; [
       # project-specific packages here
     ];
   }
   ```

   Then add `../../microvms/<name>.nix` to the VM's imports list (path is relative to `modules/`).

4. **Create workspace directory and SSH host keys**:

   ```bash
   mkdir -p ~/microvm/<name>/ssh-host-keys
   ssh-keygen -t ed25519 -N "" -f ~/microvm/<name>/ssh-host-keys/ssh_host_ed25519_key
   ```

5. **Verify** the configuration evaluates:

   ```bash
   nix eval --no-write-lock-file 'path:.#nixosConfigurations.wopr.config.microvm.vms.<name>vm.config.config.system.stateVersion'
   ```

6. **Format** with `nix fmt`.

7. **Report back** with:
   - VM name and IP address
   - How to start: `sudo systemctl start microvm@<name>vm`
   - How to SSH: `ssh sadbeast@192.168.83.X`
   - Workspace path inside VM: `~/workspace`

## Key Files

- `modules/microvm.nix` — Host bridge network config + VM declarations
- `modules/microvm-base.nix` — Base guest config function (network, shares, home-manager)
- `modules/ssh-keys.nix` — SSH authorized keys
- `microvms/` — Optional per-VM project-specific configs
