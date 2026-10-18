# Full NixOS stylix. Home-manager users on the host inherit it automatically
# (stylix's NixOS module propagates to HM), so nothing else is needed.
{inputs, ...}: {
  imports = [
    inputs.stylix.nixosModules.stylix
    ./theme.nix
  ];
}
