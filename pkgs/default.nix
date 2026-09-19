# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs ? import <nixpkgs> {}, ...}: {
  ez80asm = pkgs.callPackage ./ez80asm {};
  fab-agon-emulator = pkgs.callPackage ./fab-agon-emulator {};
  foot-terminfo = pkgs.callPackage ./foot-terminfo {};
  herdr-auto-title = pkgs.callPackage ./herdr-auto-title {};
  herdr-radar = pkgs.callPackage ./herdr-radar {};
  herdr-worktreeinclude-local = pkgs.callPackage ./herdr-worktreeinclude-local {};
  pair-invite = pkgs.callPackage ./pair-invite {};
}
