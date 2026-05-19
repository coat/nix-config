# nix-config

NixOS + home-manager + nix-darwin configuration, orchestrated with
[clan-core](https://clan.lol).

## Machines

| Host          | OS / role                        | Profile  | Managed by                    |
| ------------- | -------------------------------- | -------- | ----------------------------- |
| joshua        | desktop (sway)                   | desktop  | clan                          |
| wopr          | laptop (sway) + microvm host     | desktop  | clan                          |
| cheyenne      | public-facing web/gemini server  | server   | clan                          |
| crystalpalace | media + arr-stack server         | server   | clan                          |
| falken        | aarch64 work VM (awesome WM)     | vm       | clan                          |
| kents-MacBook-Pro | work mac                     | —        | nix-darwin (see `hosts/`)     |

## Operating

- Remote rebuild (clan): `clan machines update <host>`
- Local rebuild (on the machine): `sudo nixos-rebuild switch --flake .#<host>`
- Darwin: `sudo darwin-rebuild switch --flake .#`
- Devcontainer HM: `home-manager switch --flake .#devcontainer-<arch>-<os>`

For the full structure, runbooks ("Add a machine", "Add a user", "Add a darwin
host", "Add a microvm"), and conventions, see [AGENTS.md](./AGENTS.md).

## References

- Originally bootstrapped from
  [Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs),
  since migrated to clan-core.
- [Encrypted Btrfs Root with Opt-in State on
  NixOS](https://mt-caret.github.io/blog/2020-06-29-optin-state.html)
