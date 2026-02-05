{pkgs, ...}: {
  imports = [
    ../../features/devcontainers.nix
  ];

  home = {
    packages = with pkgs; [
      act
      amp-cli
      docker-buildx
      gcc
      github-copilot-cli
      imhex
    ];
  };
}
