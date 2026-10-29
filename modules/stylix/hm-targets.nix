# Home-manager stylix target overrides for users of system stylix (NixOS
# desktops, darwin), where stylix auto-enables every target.
{
  config,
  lib,
  ...
}: {
  # Nobody uses rofi, but stylix's target sets programs.rofi.font regardless,
  # which home-manager now warns is renamed to programs.rofi.settings.font.
  # Re-enable once stylix sets the new option.
  stylix.targets.rofi.enable = false;

  # stylix's opencode target selects its theme via programs.opencode.tui
  # (tui.json), which OpenCode 2 ignores; it reads the theme from cli.json.
  # Drop once stylix sets programs.opencode.cli.theme itself.
  programs.opencode = lib.mkIf config.stylix.targets.opencode.enable {
    tui = lib.mkForce {};
    cli.theme.name = "stylix";
  };
}
