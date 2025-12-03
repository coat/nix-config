{...}: {
  programs.foot = {
    enable = true;

    # server.enable = true;

    settings = {
      scrollback.lines = 5000;

      main = {
        underline-offset = 1;
      };
    };
  };
}
