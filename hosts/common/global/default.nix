# This holds configuration common across hosts
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.impermanence.nixosModules.impermanence
    ./sops.nix
  ]
  ++ (builtins.attrValues outputs.nixosModules);

  #home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "backup";
  home-manager.extraSpecialArgs = {
    inherit inputs outputs;
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications

      outputs.overlays.stable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    config = {
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes ca-derivations";
      accept-flake-config = true;
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
      substituters = [
        "https://cache.nixos.org/"
      ];
      trusted-substituters = [
        "https://cache.nixos.org"
        "https://nixpkgs-ruby.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nixpkgs-ruby.cachix.org-1:vrcdi50fTolOxWCZZkw0jakOnUI1T19oYJ+PRYdK4SM="
      ];
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "emacs2";
  };

  programs = {
    sway.enable = true;
    zsh.enable = true;
    git.enable = true;

    fuse.userAllowOther = true;
  };

  users.mutableUsers = false;

  users.users.sadbeast = {
    hashedPasswordFile = config.sops.secrets.sadbeast-password.path;
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGpEusv/bS34Q1JQxZXikdcwnq1vToz2d+HgV+E8NRX"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFhHC9V56/Vy7NF9xs0zfxhg3AH/pkDr7iIFyafYpwQR termux"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB0QDSnBP4zSg8LWqvSUPyR2a2fsWBUMxQhnAOUWSKDpStz10u+F6/0h3Q/kDfSCKSps24D1UJ+ic+jcG40Hf7fJl7ynHVTfs7bvYW+vNh2d8K4Y0MlhvDwGBc8d+vJ4G+ux6eKDfysFQ6rw9aWVOGFsPEPg2sk4ga8FnP+7tPNS78o2Qq3vRwCwp6W78jIMBJhgBaSscUKKg4jbHkShuD2d8Hygq5qpeDGd1SRDksh56T4nAhoHXXw+c1BWtesq8Rezdh82Z62cCxCG5Te+uBb7MmwQFwzVRaLqopGxaZTnp8fkw9uGXR1DDOx3c8BPtyV0icvOyA0iw4MnZ2YNMV343UZb/ua/tP9DExDplcbl+Z1SBtPGGvaqI852DHSZr+ZDYkTAti26rMcGPLzjdgQPUIUawcw8CU0fDT/RgaQwaQ3LN0/ohTIIBEBJwIEp01dNlrzly77/KlpAEFcNyukm3YSNLzLgH06JsqvJHtv39y/1SII02QdIw8PlYCt/FDH+3ieFdS5XUWD+fqK7DT7+q/SZQj+9XRSZClR0DMueXx+4m68l7jaO2gyMIoLjn1rJR7wMcbTerB3mTXIQKBkFxXgDE8uObSc99NWlSJVMZE/Q== anroid"
    ];

    extraGroups = ["wheel" "audio" "video"];
    shell = pkgs.zsh;
    packages = [pkgs.home-manager];
  };

  sops.secrets.sadbeast-password = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };

  home-manager.users.sadbeast = import ../../../home/sadbeast/${config.networking.hostName}.nix;

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    openssh = {
      enable = true;
      settings = {
        # Opinionated: forbid root login through SSH.
        PermitRootLogin = "no";
        # Opinionated: use keys only.
        PasswordAuthentication = false;
        X11Forwarding = true;
      };
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
    sudo.wheelNeedsPassword = false;

    pam.services = {
      swaylock = {};
    };
  };

  # environment.persistence."/persistent" = {
  #   hideMounts = true;
  #   directories = [
  #     "/var/log"
  #     "/var/lib/nixos"
  #     "/var/lib/systemd"
  #   ];
  #   files = [
  #     "/etc/machine-id"
  #     "/var/lib/sops-nix/keys.txt"
  #   ];
  # };

  # system.activationScripts.persistent-dirs.text = let
  #   mkHomePersist = user:
  #     lib.optionalString user.createHome ''
  #       mkdir -p /persistent/${user.home}
  #       chown ${user.name}:${user.group} /persistent/${user.home}
  #       chmod ${user.homeMode} /persistent/${user.home}
  #     '';
  #   users = lib.attrValues config.users.users;
  # in
  #   lib.concatLines (map mkHomePersist users);

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
