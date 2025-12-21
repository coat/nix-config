{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./global
    ./features/desktop
    ./features/games.nix
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
