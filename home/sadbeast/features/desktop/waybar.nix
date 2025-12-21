{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        layer = "bottom";
        position = "top";
        height = 22;

        modules-left = ["sway/workspaces" "sway/mode" "sway/window"];
        modules-right = ["tray" "battery" "clock"];

        "sway/workspaces" = {
          format = "{name}";
          disable-scroll = true;
        };

        "sway/mode" = {
          format = " {}";
        };

        "sway/window" = {
          max-length = 80;
          tooltip = false;
        };

        clock = {
          format = "{:%a %d %I:%M}";
          tooltip = false;
        };

        battery = {
          format = "{capacity}% {icon}";
          format-alt = "{time} {icon}";
          format-icons = ["" "" "" "" ""];
          format-charging = "{capacity}% ";
          interval = 30;

          states = {
            warning = 25;
            critical = 10;
          };

          tooltip = false;
        };

        tray = {
          icon-size = 18;
        };
      };
    };

    style = ./waybar.css;
  };
}
