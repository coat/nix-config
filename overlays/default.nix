{
  inputs,
  outputs,
}: rec {
  additions = final: prev:
    import ../pkgs {pkgs = final;};

  modifications = final: prev: {
    devcontainer = (import inputs.nixpkgs-working {
      inherit (final) system;
      config.allowUnfree = true;
    }).devcontainer;
  };

  llm-agents = inputs.llm-agents.overlays.default;

  all = [additions modifications llm-agents];
}