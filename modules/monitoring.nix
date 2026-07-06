{
  pkgs,
  config,
  ...
}: let
  vars = config.clan.core.vars.generators.grafana;
  blackboxConfig = pkgs.writeText "blackbox.yml" ''
    modules:
      icmp_probe:
        prober: icmp
        timeout: 5s
        icmp:
          preferred_ip_protocol: ip4
      dns_probe:
        prober: dns
        timeout: 5s
        dns:
          preferred_ip_protocol: ip4
          query_name: google.com
          query_type: A
      http_2xx:
        prober: http
        timeout: 10s
        http:
          method: GET
          preferred_ip_protocol: ip4
          follow_redirects: true
          valid_status_codes: []
      http_2xx_noverify:
        prober: http
        timeout: 10s
        http:
          method: GET
          preferred_ip_protocol: ip4
          follow_redirects: true
          tls_config:
            insecure_skip_verify: true
          valid_status_codes: []
  '';

  blackboxRelabelConfigs = [
    {
      source_labels = ["__address__"];
      target_label = "__param_target";
    }
    {
      source_labels = ["__param_target"];
      target_label = "instance";
    }
    {
      target_label = "__address__";
      replacement = "127.0.0.1:9115";
    }
  ];

  labeledBlackboxRelabelConfigs = [
    {
      source_labels = ["__address__"];
      target_label = "__param_target";
    }
    {
      target_label = "__address__";
      replacement = "127.0.0.1:9115";
    }
  ];
in {
  clan.core.vars.generators.grafana = {
    share = true;
    files.grafana-secret-key = {
      secret = true;
      owner = "grafana";
      group = "grafana";
    };
    files.grafana-admin-password = {
      secret = true;
      owner = "grafana";
      group = "grafana";
    };
    prompts.secret-key = {
      description = "Grafana secret key for signing and encryption";
      type = "hidden";
    };
    prompts.admin-password = {
      description = "Grafana admin password";
      type = "hidden";
    };
    script = ''
      cp "$prompts/secret-key" "$out/grafana-secret-key"
      cp "$prompts/admin-password" "$out/grafana-admin-password"
    '';
  };

  services.prometheus.exporters.systemd = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9558;
    extraFlags = [
      "--systemd.collector.unit-include=transmission.service|jellyfin.service|radarr.service|sonarr.service|prowlarr.service|bazarr.service|readarr.service|podman-dispatcharr.service|podman-romm.service"
    ];
  };

  services.prometheus.exporters.blackbox = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9115;
    configFile = blackboxConfig;
  };

  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9090;
    retentionTime = "90d";
    globalConfig = {
      scrape_interval = "60s";
      evaluation_interval = "60s";
    };
    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [{targets = ["127.0.0.1:9090"];}];
      }
      {
        job_name = "systemd";
        static_configs = [{targets = ["127.0.0.1:9558"];}];
      }
      {
        job_name = "blackbox-icmp";
        scrape_interval = "30s";
        metrics_path = "/probe";
        params = {module = ["icmp_probe"];};
        static_configs = [
          {
            targets = ["192.168.0.1"];
            labels = {instance = "Gateway";};
          }
          {
            targets = ["1.1.1.1"];
            labels = {instance = "Cloudflare DNS";};
          }
          {
            targets = ["8.8.8.8"];
            labels = {instance = "Google DNS";};
          }
        ];
        relabel_configs = labeledBlackboxRelabelConfigs;
      }
      {
        job_name = "blackbox-dns";
        metrics_path = "/probe";
        params = {module = ["dns_probe"];};
        static_configs = [
          {
            targets = ["1.1.1.1:53"];
            labels = {instance = "Cloudflare DNS";};
          }
          {
            targets = ["8.8.8.8:53"];
            labels = {instance = "Google DNS";};
          }
        ];
        relabel_configs = labeledBlackboxRelabelConfigs;
      }
      {
        job_name = "blackbox-http-external";
        metrics_path = "/probe";
        params = {module = ["http_2xx"];};
        static_configs = [
          {
            targets = ["https://google.com"];
            labels = {instance = "Google";};
          }
          {
            targets = ["https://cloudflare.com"];
            labels = {instance = "Cloudflare";};
          }
        ];
        relabel_configs = labeledBlackboxRelabelConfigs;
      }
      {
        job_name = "blackbox-http-internal";
        metrics_path = "/probe";
        params = {module = ["http_2xx_noverify"];};
        static_configs = [
          {
            targets = ["http://127.0.0.1:8096"];
            labels = {instance = "Jellyfin";};
          }
          {
            targets = ["http://127.0.0.1:7878"];
            labels = {instance = "Radarr";};
          }
          {
            targets = ["http://127.0.0.1:8989"];
            labels = {instance = "Sonarr";};
          }
          {
            targets = ["http://127.0.0.1:9696"];
            labels = {instance = "Prowlarr";};
          }
          {
            targets = ["http://127.0.0.1:5055"];
            labels = {instance = "Seerr";};
          }
          {
            targets = ["http://127.0.0.1:9191"];
            labels = {instance = "Dispatcharr";};
          }
          {
            targets = ["http://127.0.0.1:8080"];
            labels = {instance = "RomM";};
          }
        ];
        relabel_configs = labeledBlackboxRelabelConfigs;
      }
    ];
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3010;
        domain = "grafana.local";
      };
      security = {
        admin_user = "admin";
        admin_password = "$__file{${vars.files.grafana-admin-password.path}}";
        secret_key = "$__file{${vars.files.grafana-secret-key.path}}";
      };
      analytics.reporting_enabled = false;
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          access = "proxy";
          url = "http://127.0.0.1:9090";
          isDefault = true;
          editable = false;
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [3010];
}
