# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs ? import <nixpkgs> {}, ...}: {
  ez80asm = pkgs.callPackage ./ez80asm {};
  fab-agon-emulator = pkgs.callPackage ./fab-agon-emulator {};
}
