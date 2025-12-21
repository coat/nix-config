{inputs, ...}: {
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
