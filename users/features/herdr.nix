{pkgs, ...}: {
  home = {
    file.".config/herdr/config.toml".text = ''
      onboarding = false

      [keys]
      prefix = "ctrl+a"

      [theme]
      name = "terminal"
    '';

    packages = [pkgs.herdr];
  };
}
