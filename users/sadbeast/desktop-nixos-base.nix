{
  imports = [
    ../../modules/desktop-nixos-base.nix
    {
      clan.core.vars.generators.syncthing = {
        share = true;
        prompts.password-input = {
          description = "Syncthing WebUI password";
          type = "hidden";
        };
        files.password.secret = true;
        script = ''
          cat $prompts/password-input > $out/password
        '';
      };
    }
  ];
}
