#!/usr/bin/env bash

sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --no-daemon
. ~/.nix-profile/etc/profile.d/nix.sh
nix --extra-experimental-features nix-command --extra-experimental-features flakes run home-manager -- switch -b backup --flake ~/dotfiles#node --extra-experimental-features nix-command --extra-experimental-features flakes
rm -rf ~/.config/nvim && cp -r ~/dotfiles/home/features/nvim ~/.config/
