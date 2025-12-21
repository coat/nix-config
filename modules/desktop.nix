{inputs, ...}: {
  imports = [
    inputs.stylix.nixosModules.stylix
    ./stylix.nix
  ];

  programs = {
    sway.enable = true;
  };

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
    # rtkit is optional but recommended
    rtkit.enable = true;

    pam.services = {
      swaylock = {};
    };
  };
}
