{
  inputs,
  pkgs,
  ...
}: {
  # sadbeast's home-manager desktop bundle. Imported by per-host home.nix files.
  imports = [
    ../features/desktop
    ../features/desktop/sway.nix
    ../features/desktop/waybar.nix
    ../features/desktop/dev.nix
    ../features/dev.nix
    ../features/senpai.nix
    inputs.gasim.homeModules.default
  ];

  home.packages = [pkgs.pair-invite];

  # gasim and gasim-gui, its fonts and colors from stylix
  programs.gasim.enable = true;

  programs.librewolf.profiles.sadbeast = {};
  programs.obsidian.vaults.personal.target = "docs/vault/personal";
  # Syncthing once propagated this HM symlink to peers where its store path
  # didn't exist, so Obsidian replaced it with a plain file. It's no longer
  # synced (modules/syncthing-vault.nix); force replaces leftover copies.
  home.file."docs/vault/personal/.obsidian/appearance.json".force = true;

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
