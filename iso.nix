# Build:
# nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=iso.nix
#
# Test:
# $ nix-shell -p qemu --run "qemu-system-x86_64 -enable-kvm -m 256 -cdrom result/iso/nixos-*.iso"
{
  pkgs,
  ...
}: {
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];
  environment.systemPackages = [pkgs.git pkgs.sops];

  # The build process is slow because of compression - use a faster compressor
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  console.keyMap = "emacs2";
}
