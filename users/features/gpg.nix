{
  pkgs,
  config,
  lib,
  ...
}: let
  # On desktops, use the GUI pinentry only when the requesting gpg has a
  # display; over SSH fall back to curses on the caller's tty. gpg forwards
  # PINENTRY_USER_DATA from the client env to the pinentry process, which is
  # the documented hook for this (zsh sets it below for SSH sessions). The
  # DISPLAY check is a second line of defence for non-zsh callers.
  pinentrySwitch = pkgs.writeShellScriptBin "pinentry" ''
    case "''${PINENTRY_USER_DATA-}" in
      *tty*) exec ${pkgs.pinentry-curses}/bin/pinentry-curses "$@" ;;
    esac
    if [ -z "''${WAYLAND_DISPLAY-}" ] && [ -z "''${DISPLAY-}" ]; then
      exec ${pkgs.pinentry-curses}/bin/pinentry-curses "$@"
    fi
    exec ${pkgs.pinentry-gnome3}/bin/pinentry "$@"
  '';

  pinentryPackage =
    if pkgs.stdenv.hostPlatform.isDarwin
    then pkgs.pinentry_mac
    else if config.gtk.enable
    then pinentrySwitch
    else pkgs.pinentry-tty;
in {
  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    pinentry.package = pinentryPackage;
    # Lets `gpg --pinentry-mode loopback` (and pass via
    # PASSWORD_STORE_GPG_OPTS) prompt on the tty as a last resort.
    extraConfig = "allow-loopback-pinentry";
  };

  home.packages = lib.optional config.gtk.enable pkgs.gcr_3;

  programs = let
    fixGpg =
      /*
      bash
      */
      ''
        gpgconf --launch gpg-agent
      '';
  in {
    # Start gpg-agent if it's not running or tunneled in
    # SSH does not start it automatically, so this is needed to avoid having to use a gpg command at startup
    # https://www.gnupg.org/faq/whats-new-in-2.1.html#autostart
    zsh.loginExtra = fixGpg;

    # Ask for a tty pinentry when this shell came in over SSH.
    zsh.initContent = ''
      [ -n "''${SSH_CONNECTION-}" ] && export PINENTRY_USER_DATA=tty
    '';

    gpg = {
      enable = true;
      settings = {
        trust-model = "tofu+pgp";
      };
      # publicKeys = [
      #   {
      #     source = ../../pgp.asc;
      #     trust = 5;
      #   }
      # ];
    };
  };

  systemd.user.services = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    # Link /run/user/$UID/gnupg to ~/.gnupg-sockets
    # So that SSH config does not have to know the UID
    link-gnupg-sockets = {
      Unit = {
        Description = "link gnupg sockets from /run to /home";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.coreutils}/bin/ln -Tfs /run/user/%U/gnupg %h/.gnupg-sockets";
        ExecStop = "${pkgs.coreutils}/bin/rm $HOME/.gnupg-sockets";
        RemainAfterExit = true;
      };
      Install.WantedBy = ["default.target"];
    };
  };
}
