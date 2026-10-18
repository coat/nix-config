# Every clan machine (imported by mkMachine in clan.nix).
{pkgs, ...}: {
  imports = [
    ./base.nix
    ./zerotier-hosts.nix
  ];

  environment.systemPackages = [pkgs.ghostty.terminfo];

  programs.fuse.userAllowOther = true;

  services = {
    resolved.settings.Resolve.MulticastDNS = "no";

    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
      };
    };

    openssh.extraConfig = ''
      AcceptEnv COLORTERM
    '';
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  console.keyMap = "emacs2";
}
