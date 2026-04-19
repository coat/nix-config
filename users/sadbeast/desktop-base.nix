{
  # Common desktop home-manager configuration
  imports = [
    ./home.nix
    ../features/desktop
    ../features/desktop/dev.nix
    ../features/dev.nix
  ];

  programs.librewolf.profiles.sadbeast = {};
  programs.nixvim.plugins = {
    obsidian.settings = {
      workspaces = [
        {
          name = "personal";
          path = "~/docs/vault/personal";
        }
      ];
    };
  };

  stylix.targets.librewolf.profileNames = ["sadbeast"];

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  gtk.gtk4.theme = null;
}
