{osConfig, ...}: {
  programs.senpai = {
    enable = true;
    config = {
      address = "ircs://irc.sadbeast.com:6697";
      nickname = "sadbeast";
      password-cmd = ["cat" osConfig.clan.core.vars.generators.soju-client.files.password.path];
    };
  };
}
