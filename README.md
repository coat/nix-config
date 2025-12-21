# nix-config

Welcome to my NixOS configurations. I have no idea what I'm doing.

## machines

Most machines are managed using [clan](https://clan.lol). After making changes,
run:

```sh
clan machines update
```

to update every machine remotely. `clan machines update wopr` to update a
specific machine.

From an actual machine, if no secrets have been changed, you can run `sudo
nixos-rebuild switch --flake .#<machine>`.

## hosts

Some machines are not managed using clan, like darwin. After making changes,
run:

```sh
sudo darwin-rebuild switch --flake .#
```

which will rebuild darwin nixos and run home-manager switch.

## home-manager

`clan machines update` and `nixos-rebuild switch` will run home-manager.

# References
- This was initially setup using
  [https://github.com/Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs)

- [Encypted Btrfs Root with Opt-in State on
  NixOS](https://mt-caret.github.io/blog/2020-06-29-optin-state.html)
