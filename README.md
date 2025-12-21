# nix-config

## hosts

Use [clan](https://clan.lol) to manage machines remotely:

```sh
clan machines update
```

Or, if you are on the machine:

```sh
sudo nixos-rebuild switch --flake .#hostname
```

## home-manager

```sh
home-manager switch --flake .#sadbeast@hostname
```

# References
This was intitially setup using [https://github.com/Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs)

[Encypted Btrfs Root with Opt-in State on NixOS](https://mt-caret.github.io/blog/2020-06-29-optin-state.html)
