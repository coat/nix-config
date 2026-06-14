{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    dmenu
    i3lock
    i3status
    iosevka
    nerd-fonts.iosevka
    nsxiv
    scrot
    xclip
  ];

  home.keyboard = {
    layout = "us";
    options = ["ctrl:nocaps"];
  };

  xsession.windowManager.i3 = {
    enable = true;

    config = let
      modifier = "Mod4";
    in {
      inherit modifier;

      defaultWorkspace = "workspace number 1";

      terminal = lib.mkDefault "${pkgs.ghostty}/bin/ghostty";

      bars = [
        {
          position = "top";
          statusCommand = "${pkgs.i3status}/bin/i3status";
        }
      ];

      gaps = {
        smartGaps = true;
        outer = 0;
      };

      window.commands = [
        {
          command = "floating enable";
          criteria.class = "Qalculate-gtk";
        }
      ];

      keybindings = lib.mkOptionDefault {
        "${modifier}+d" = "exec ${pkgs.dmenu}/bin/dmenu_run";
        "${modifier}+p" = "exec passmenu";
        "${modifier}+Shift+Return" = "exec qutebrowser";
        "${modifier}+y" = "exec ${pkgs.scrot}/bin/scrot ~/scrn-$(date +'%Y-%m-%d-%H-%M-%S').png";
        "${modifier}+Shift+y" = "exec ${pkgs.scrot}/bin/scrot -s ~/scrn-$(date +'%Y-%m-%d-%H-%M-%S').png";
        "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+";
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%+";
        "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
      };
    };

    extraConfig = ''
      default_border pixel 1
      default_floating_border normal
      hide_edge_borders smart
    '';
  };

  services = {
    dunst.enable = true;

    screen-locker = {
      enable = true;
      lockCmd = "${pkgs.i3lock}/bin/i3lock -c 000000";
    };
  };
}
