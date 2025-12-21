{config, ...}: {
  # Wireless PSK stored using Clan Vars
  clan.core.vars.generators.wireless = {
    files.wpa-secrets = {
      secret = true;
      neededFor = "users";
    };
    prompts.home-psk = {
      description = "WPA PSK for 'Black Vulture' network";
      type = "hidden";
    };
    script = ''
      cat > "$out/wpa-secrets" <<EOF
      home_psk=$(cat "$prompts/home-psk")
      EOF
    '';
  };

  networking.wireless = {
    enable = true;
    fallbackToWPA2 = false;

    # Declarative
    secretsFile = config.clan.core.vars.generators.wireless.files.wpa-secrets.path;
    networks = {
      "Black Vulture" = {
        pskRaw = "ext:home_psk";
      };
    };

    # Imperative
    allowAuxiliaryImperativeNetworks = true;
    userControlled = {
      enable = true;
      group = "network";
    };
    extraConfig = ''
      update_config=1
    '';
  };

  # Ensure group exists
  users.groups.network = {};

  systemd.services.wpa_supplicant.preStart = "touch /etc/wpa_supplicant.conf";
}
