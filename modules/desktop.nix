{
  imports = [
    ./docker.nix
    ./stylix/nixos.nix
  ];

  programs.dconf.enable = true;

  services = {
    avahi = {
      enable = true;
      openFirewall = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    printing.enable = true;
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };
}
