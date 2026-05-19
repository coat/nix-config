{inputs, ...}: {
  # Wires HM-level stylix for hosts that do NOT load the NixOS stylix module
  # (servers, standalone home-manager, microvm guests). Desktop hosts get HM
  # stylix auto-propagated from `inputs.stylix.nixosModules.stylix`.
  home-manager.sharedModules = [
    inputs.stylix.homeModules.stylix
    ./stylix.nix
    {
      stylix = {
        autoEnable = false;
        targets.btop.enable = true;
        targets.fzf.enable = true;
        targets.nixvim.enable = true;
        targets.starship.enable = true;
        targets.tmux.enable = true;
      };
    }
  ];
}
