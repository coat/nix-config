{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  stylix = {
    enable = true;

    base16Scheme = "${pkgs.base16-schemes}/share/themes/default-dark.yaml";
    polarity = "dark";

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.iosevka;
        name = "Iosevka";
      };
    };
  };

  programs = {
    htop.enable = true;
    zsh.enable = true;

    fuse.userAllowOther = true;
  };

  services = {
    # avahi = {
    #   enable = true;
    #   openFirewall = true;
    # };

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
      };
    };
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "emacs2";
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  security.sudo.wheelNeedsPassword = false;
}

