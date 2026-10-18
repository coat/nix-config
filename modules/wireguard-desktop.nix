# On-demand full-tunnel PIA VPN for desktops:
#   sudo systemctl start pia-wg-desktop   /   stop pia-wg-desktop
{
  config,
  pkgs,
  ...
}: let
  wgConfPath = "/run/pia-wg-desktop/wg0.conf";

  connectScript = import ./pia/connect-script.nix {
    inherit pkgs config wgConfPath;
    name = "pia-wg-desktop-connect";
    postConnect = ''
      wg-quick up "${wgConfPath}"
    '';
  };

  disconnectScript = pkgs.writeShellApplication {
    name = "pia-wg-desktop-disconnect";
    runtimeInputs = with pkgs; [wireguard-tools];
    text = ''
      if [[ -f "${wgConfPath}" ]]; then
        wg-quick down "${wgConfPath}" || true
      fi
    '';
  };
in {
  imports = [./pia/credentials.nix];

  systemd.services.pia-wg-desktop = {
    description = "PIA WireGuard Desktop VPN";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${connectScript}/bin/pia-wg-desktop-connect";
      ExecStop = "${disconnectScript}/bin/pia-wg-desktop-disconnect";
      RuntimeDirectory = "pia-wg-desktop";
      RuntimeDirectoryMode = "0700";
    };
  };
}
