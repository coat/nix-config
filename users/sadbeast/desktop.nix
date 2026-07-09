{
  imports = [
    ../../modules/desktop-host.nix
  ];

  # soju bouncer password, read by senpai (users/features/senpai.nix) via
  # password-cmd; shared so every desktop gets the same account secret
  clan.core.vars.generators.soju-client = {
    share = true;
    files.password = {
      secret = true;
      owner = "sadbeast";
      mode = "0400";
    };
    prompts.password = {
      description = "soju IRC bouncer password for sadbeast";
      type = "hidden";
    };
    script = ''
      cp "$prompts/password" "$out/password"
    '';
  };
}
