{lib, ...}: {
  imports = [
    ../features/global.nix
  ];

  home = {
    username = "sadbeast";
    homeDirectory = "/home/sadbeast";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "25.05";
  };

  programs = {
    git.settings.user.name = "Sad Beast";
    git.settings.user.email = lib.mkDefault "sadbeast@sadbeast.com";

    nixvim.plugins = {
      obsidian.settings = {
        workspaces = [
          {
            name = "personal";
            path = "~/docs/vault/personal";
          }
        ];
      };
    };
  };
}
