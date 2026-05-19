{
  inputs,
  outputs,
}: rec {
  additions = final: prev:
    import ../pkgs {pkgs = final;};

  modifications = final: prev: {
    devcontainer =
      (import inputs.nixpkgs-working {
        inherit (final) system;
        config.allowUnfree = true;
      }).devcontainer;
  };

  llm-agents = inputs.llm-agents.overlays.default;

  all = final: prev:
    (additions final prev)
    // (modifications final prev)
    // (llm-agents final prev);
}
