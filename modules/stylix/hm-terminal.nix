# Home-manager stylix for places without NixOS/darwin stylix (servers,
# microvm guests, standalone devcontainers): terminal targets only.
{inputs, ...}: {
  imports = [
    inputs.stylix.homeModules.stylix
    ./theme.nix
  ];

  stylix = {
    autoEnable = false;
    targets.btop.enable = true;
    targets.fzf.enable = true;
    targets.nixvim.enable = true;
    targets.starship.enable = true;
    targets.tmux.enable = true;
    targets.herdr.enable = true;
  };
}
