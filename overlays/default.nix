{
  inputs,
  outputs,
}: {
  # For every flake input, aliases 'pkgs.inputs.${flake}' to
  # 'inputs.${flake}.packages.${pkgs.system}' or
  # 'inputs.${flake}.legacyPackages.${pkgs.system}'
  flake-inputs = final: _: {
    inputs =
      builtins.mapAttrs (
        _: flake: let
          legacyPackages = (flake.legacyPackages or {}).${final.system} or {};
          packages = (flake.packages or {}).${final.system} or {};
        in
          if legacyPackages != {}
          then legacyPackages
          else packages
      )
      inputs;
  };

  # Adds pkgs.stable == inputs.nixpkgs-stable.legacyPackages.${pkgs.system}
  stable = final: _: {
    stable = inputs.nixpkgs-stable.legacyPackages.${final.system};
  };
  # Adds my custom packages
  additions = final: prev:
    import ../pkgs {pkgs = final;};

  modifications = final: prev: {
    # ruby = prev.ruby.overrideAttrs (oldAttrs: {
    #   defaultGemConfig =
    #     prev.defaultGemConfig
    #     // {
    #       ruby-lsp = attrs: {
    #         dontBuild = false;
    #         postPatch = ''
    #         substituteInPlace lib/ruby_lsp/setup_bundler.rb \
    #           --replace 'Bundler::CLI::Install.new({ "no-cache" => true }).run' ' '
    #         '';
    #       };
    #     };
    # });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
