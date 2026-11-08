{
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;

    # Centralize each project's direnv cache under ~/.cache/direnv/layouts/
    # (human-readable `<hash><path>` dirs, per the direnv wiki), so they can be
    # garbage-collected in one place instead of scattered `.direnv` dirs.
    # `shasum` fallback keeps this working on darwin, which lacks `sha1sum`.
    stdlib = ''
      : "''${XDG_CACHE_HOME:="''${HOME}/.cache"}"
      declare -A direnv_layout_dirs
      direnv_layout_dir() {
          local hash path
          echo "''${direnv_layout_dirs[$PWD]:=$(
              if command -v sha1sum >/dev/null 2>&1; then
                  hash="$(sha1sum - <<< "$PWD" | head -c40)"
              else
                  hash="$(shasum -a 1 <<< "$PWD" | head -c40)"
              fi
              path="''${PWD//[^a-zA-Z0-9]/-}"
              echo "''${XDG_CACHE_HOME}/direnv/layouts/''${hash}''${path}"
          )}"
      }
    '';
  };
}
