{
  pkgs,
  ...
}: {
  imports = [
    ./global
    ./features/desktop
    ./features/dev.nix
    ./features/games.nix
    ./features/awesome
  ];

  home = {
    packages = with pkgs; [
      awscli2
      # localstack
      pipx
    ];

    sessionPath = [
      "/home/sadbeast/.local/bin"
    ];
  };
}
