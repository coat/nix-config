{
  outputs,
  ...
}: {
  imports =
    [
      ../features/global.nix
      ../features/dev.nix
    ];

  home.username = "vscode";
}
