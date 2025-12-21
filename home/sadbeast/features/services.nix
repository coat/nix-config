{pkgs, ...}: {
  services = {
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
