{...}: {
  programs.foot = {
    enable = true;

    settings = {
      scrollback.lines = 5000;

      main = {
        underline-offset = 1;
      };
    };
  };
}
