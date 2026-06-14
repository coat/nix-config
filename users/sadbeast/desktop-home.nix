{pkgs, ...}: {
  # sadbeast's home-manager desktop bundle. Imported by per-host home.nix files.
  imports = [
    ../features/desktop
    ../features/desktop/sway.nix
    ../features/desktop/waybar.nix
    ../features/desktop/dev.nix
    ../features/dev.nix
  ];

  home.packages = [pkgs.zoom-us];

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
}
