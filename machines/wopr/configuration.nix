{...}: {
  imports = [
    ./hardware-configuration.nix

    ../../users/sadbeast/nixos.nix
    ../../modules/global.nix
    ../../modules/desktop.nix
    ../../modules/wireless.nix
    ../../modules/wireguard.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "wopr";

  # Slows down write operations considerably
  nix.settings.auto-optimise-store = false;

  services = {
    logind.settings.Login = {
      HandleLidSwitchExternalPower = "ignore";
    };
  };

  users.users.sadbeast = {
    extraGroups = ["docker" "audio"];

    subUidRanges = [
      {
        startUid = 100000;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 100000;
        count = 65536;
      }
    ];
  };

  # home-manager.users.sadbeast = import ../../users/sadbeast/${config.networking.hostName}.nix;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
