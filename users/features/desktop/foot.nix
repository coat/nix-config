{...}: {
  programs.foot = {
    enable = true;

    # server.enable = true;

    settings = {
      scrollback.lines = 5000;

      main = {
        font = "Iosevka-12:style=Medium,Regular";
        font-bold = "Iosevka-12:style=Bold";
        font-italic = "Iosevka-12:style=Italic";

        underline-offset = 1;
      };
    };
  };
}
