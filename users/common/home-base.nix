# Base home-manager module for every user: shared features plus identity.
# Set `me.username` (and optionally realName/email) in users/<user>/home.nix.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.me;
in {
  imports = [../features/global.nix];

  options.me = {
    username = lib.mkOption {
      type = lib.types.str;
      description = "Login name.";
    };
    realName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Name used for git commits.";
    };
    email = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Default git email (repos may override).";
    };
  };

  config = {
    home = {
      inherit (cfg) username;
      homeDirectory =
        if pkgs.stdenv.hostPlatform.isDarwin
        then "/Users/${cfg.username}"
        else "/home/${cfg.username}";
      stateVersion = lib.mkDefault "25.05";
    };

    programs.git.settings.user = {
      name = lib.mkIf (cfg.realName != null) cfg.realName;
      email = lib.mkIf (cfg.email != null) (lib.mkDefault cfg.email);
    };
  };
}
