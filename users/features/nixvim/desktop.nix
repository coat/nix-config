{
  programs.nixvim = {
    imports = [
      ./nixvim/dev.nix
      ./nixvim/obsidian.nix
    ];
  };
}
