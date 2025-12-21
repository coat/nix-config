#!/usr/bin/env bash

ARCH="$(uname -m)"
OS="$(uname -s)"

if [[ "$OS" == "Darwin" ]]; then
  SYSTEM="aarch64-darwin"
elif [[ "$ARCH" == "x86_64" ]]; then
  SYSTEM="x86_64-linux"
elif [[ "$ARCH" == "aarch64" ]]; then
  SYSTEM="aarch64-linux"
else
  echo "Unsupported system: $OS/$ARCH"
  exit 1
fi

FLAKE="${1:-devcontainer-$SYSTEM}"

sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --no-daemon
. ~/.nix-profile/etc/profile.d/nix.sh
nix --extra-experimental-features nix-command --extra-experimental-features flakes run home-manager -- switch -b backup --flake ~/dotfiles#${FLAKE} --extra-experimental-features nix-command --extra-experimental-features flakes
