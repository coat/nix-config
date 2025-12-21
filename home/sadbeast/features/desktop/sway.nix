{
  config,
  lib,
  pkgs,
  ...
}: {
  fonts.fontconfig.enable = true;

  home = {
    sessionVariables = {
      XDG_CURRENT_DESKTOP = "sway";
      MOZ_ENABLE_WAYLAND = 1;
      QT_QPA_PLATFORM = "wayland";
      LIBSEAT_BACKEND = "logind";
      SDL_VIDEODRIVER = "wayland";
    };
    packages = with pkgs; [
      grim
      iosevka
      nerd-fonts.iosevka
      light
      slurp
      swayimg
      wl-clipboard
      dmenu-wayland
      xwayland
    ];

    pointerCursor = {
      gtk.enable = true;
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      size = 22;
    };
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.gnome-themes-extra;
      # name = "Adwaita-dark";
      name = "Adwaita";
    };
  };

  wayland.windowManager.sway = {
    enable = true;

    config = {
      modifier = "Mod4";

      bars = [];

      fonts = {
        names = ["Iosevka"];
        size = 10.0;
      };

      gaps = {
        smartGaps = true;
        outer = 0;
      };

      input = {
        "*" = {
          xkb_layout = "us";
          xkb_options = "ctrl:nocaps";
          tap = "enabled";
        };
      };

      window.commands = [
        {
          command = "floating enable";
          criteria = {
            app_id = "galculator";
          };
        }
      ];

      keybindings = let
        modifier = config.wayland.windowManager.sway.config.modifier;
      in
        lib.mkOptionDefault {
          "${modifier}+p" = "exec passmenu";
          "${modifier}+Shift+Return" = "exec qutebrowser";
          "${modifier}+y" = "exec grim ~/scrn-$(date +\"%Y-%m-%d-%H-%M-%S\").png";
          "${modifier}+Shift+y" = "exec slurp | grim -g - ~/scrn-$(date +\"%Y-%m-%d-%H-%M-%S\").png";
          "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ && wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/[^0-9]//g' > $XDG_RUNTIME_DIR/wob.sock";
          "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%- && wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/[^0-9]//g' > $XDG_RUNTIME_DIR/wob.sock";
          "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && (wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo 0 > $XDG_RUNTIME_DIR/wob.sock) || wpctl get-volume @DEFAULT_AUDIO_SINK@ > $XDG_RUNTIME_DIR/wob.sock";

          "XF86MonBrightnessUp" = "exec light -A 5 && light -G | cut -d'.' -f1 > $XDG_RUNTIME_DIR/wob.sock";
          "XF86MonBrightnessDown" = "exec light -U 5 && light -G | cut -d'.' -f1 > $XDG_RUNTIME_DIR/wob.sock";
        };

      startup = [
        {
          command = "systemctl --user restart waybar";
          always = true;
        }
      ];

      terminal = "${pkgs.foot}/bin/foot";
      # terminal = "${pkgs.ghostty}/bin/ghostty";
    };

    extraConfig = ''
      # Window borders
      default_border pixel 1
      default_floating_border normal
      hide_edge_borders smart
    '';
  };

  programs = {
    swaylock.enable = true;
  };

  services = {
    mako = {
      enable = true;

      extraConfig = ''
        [mode=do-not-disturb]
        invisible=1
      '';
    };

    pasystray.enable = true;

    swayidle = {
      enable = true;

      events = [
        # { event = "timeout 300"; command = "${pkgs.swaylock}/bin/swaylock -fF -c 000000"; }
        # { event = "timeout 600"; command = "swaymsg \"output * dpms off\""; }
        {
          event = "after-resume";
          command = "swaymsg \"output * dpms on\"";
        }
        {
          event = "before-sleep";
          command = "${pkgs.swaylock}/bin/swaylock -fF -c 000000";
        }
      ];
    };
    wob.enable = true;
  };
}
