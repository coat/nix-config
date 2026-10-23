# Home-manager stylix target overrides for users of system stylix (NixOS
# desktops, darwin), where stylix auto-enables every target.
{
  # Nobody uses rofi, but stylix's target sets programs.rofi.font regardless,
  # which home-manager now warns is renamed to programs.rofi.settings.font.
  # Re-enable once stylix sets the new option.
  stylix.targets.rofi.enable = false;
}
