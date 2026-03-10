{pkgs, ...}: {
  imports = [
    ../../features/devcontainers.nix
  ];

  home = {
    packages = with pkgs; [
      act
      docker-buildx
      imhex
    ];
  };
}
