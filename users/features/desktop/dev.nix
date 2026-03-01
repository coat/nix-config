{pkgs, ...}: {
  imports = [
    ../../features/devcontainers.nix
  ];

  home = {
    packages = with pkgs; [
      act
      docker-buildx
      imhex
      pkgs.llm-agents.amp
      pkgs.llm-agents.copilot-cli
      pkgs.llm-agents.opencode
      pkgs.llm-agents.spec-kit
    ];
  };
}
