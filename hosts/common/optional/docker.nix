{
  ...
}: {
  virtualisation = {
    docker = {
      enable = true;

      daemon.settings = {
        # userland-proxy = false;
        # experimental = true;
        # metrics-addr = "0.0.0.0:9323";
        # ipv6 = true;
        # fixed-cidr-v6 = "fd00::/80";

        log-opts = {
          compress = "false";
        };
      };

      logDriver = "local";
      # rootless = {
      #   enable = true;
      #   setSocketVariable = true;
      # };
      storageDriver = "btrfs";
    };
  };
}
