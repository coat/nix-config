{
  imports = [
    ../../modules/home-manager-stylix.nix
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

  users.users.sadbeast.extraGroups = ["video" "audio"];
}
