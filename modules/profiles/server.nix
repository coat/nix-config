# Headless servers (cheyenne, crystalpalace). No NixOS-level stylix, so HM
# gets the terminal-only theme directly.
{
  imports = [
    ../home-manager-stylix.nix
  ];
}
