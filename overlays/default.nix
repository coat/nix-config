{
  inputs,
  outputs,
}: {
  # For every flake input, aliases 'pkgs.inputs.${flake}' to
  # 'inputs.${flake}.packages.${pkgs.stdenv.hostPlatform.system}' or
  # 'inputs.${flake}.legacyPackages.${pkgs.stdenv.hostPlatform.system}'
  flake-inputs = final: _: {
    inputs =
      builtins.mapAttrs (
        _: flake: let
          legacyPackages = (flake.legacyPackages or {}).${final.stdenv.hostPlatform.system} or {};
          packages = (flake.packages or {}).${final.stdenv.hostPlatform.system} or {};
        in
          if legacyPackages != {}
          then legacyPackages
          else packages
      )
      inputs;
  };

  # Adds pkgs.stable == inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system}
  stable = final: _: {
    stable = inputs.nixpkgs-stable.legacyPackages.${final.stdenv.hostPlatform.system};
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
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}
