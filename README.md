# nix-config

## machines

Most machines are managed using [clan](https://clan.lol). After making changes,
run:

```sh
clan machines update
```

to update every machine managed by clan.

## hosts

Some machines are not managed using clan, like darwin. After making changes, run:

```sh
darwin-rebuild
```

which will rebuild darwin nixos and run home-manager switch.

## home-manager

`clan machines update` will run home-manager. To apply changes to config in the `/users` directory directly from the machine instead, run:

```sh
home-manager switch --flake .#sadbeast@hostname
```

# References
- This was intitially setup using [https://github.com/Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs)

- [Encypted Btrfs Root with Opt-in State on NixOS](https://mt-caret.github.io/blog/2020-06-29-optin-state.html)
