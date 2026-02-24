{
  inputs,
  outputs,
}: rec {
  additions = final: prev:
    import ../pkgs {pkgs = final;};

  modifications = final: prev: {
  };

  llm-agents = inputs.llm-agents.overlays.default;

  all = [additions modifications llm-agents];
}