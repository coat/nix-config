# Headless servers (cheyenne, crystalpalace). No NixOS-level stylix, so HM
# gets the terminal-only theme directly.
{
  home-manager.sharedModules = [../stylix/hm-terminal.nix];
}
