{inputs}: rec {
  # Custom packages from ../pkgs.
  additions = final: prev:
    import ../pkgs {pkgs = final;};

  # Pinned or overridden upstream packages. Empty for now; add overrides here
  # with a comment saying when they can be dropped.
  modifications = final: prev: {};

  herdr = inputs.herdr.overlays.default;

  all = final: prev:
    (additions final prev)
    // (modifications final prev)
    // (herdr final prev);
}
