{
  pkgs,
  lib,
  config,
  ...
}: let
  vars = config.clan.core.vars.generators.forgejo-runner;
  runnerLabels = [
    "ubuntu-latest:docker://node:22-bookworm"
    "nixos-latest:docker://nixos/nix"
  ];
in {
  clan.core.vars.generators.forgejo-runner = {
    share = true;
    files.runner-uuid-env.secret = false;
    files.runner-token-env.secret = true;
    prompts.runner-uuid = {
      description = "Forgejo Actions runner UUID for codeberg.org";
    };
    prompts.runner-token = {
      description = "Forgejo Actions runner token for codeberg.org";
      type = "hidden";
    };
    script = ''
      cp "$prompts/runner-uuid" "$out/runner-uuid-env"
      echo "TOKEN=$(cat "$prompts/runner-token")" > "$out/runner-token-env"
    '';
  };

  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances.codeberg = {
      enable = true;
      name = "crystalpalace";
      url = "https://codeberg.org";
      tokenFile = vars.files.runner-token-env.path;
      labels = runnerLabels;
    };
  };

  systemd.services."gitea-runner-codeberg" = {
    serviceConfig = {
      ExecStartPre = lib.mkForce "+${pkgs.writeShellScript "forgejo-runner-setup" ''
        set -e
        CONFIG="/var/lib/gitea-runner/codeberg/config.yaml"

        TOKEN=$(sed 's/^TOKEN=//' "${vars.files.runner-token-env.path}")
        UUID=$(cat "${vars.files.runner-uuid-env.path}")

        mkdir -p "$(dirname "$CONFIG")"

        cat > "$CONFIG" <<YAMLEOF
        server:
          connections:
            codeberg:
              url: https://codeberg.org
              uuid: ''${UUID}
              token: ''${TOKEN}
        runner:
          labels:
            - ubuntu-latest:docker://node:22-bookworm
            - nixos-latest:docker://nixos/nix
        YAMLEOF

        chmod 644 "$CONFIG"
      ''}";

      ExecStart = lib.mkForce "${pkgs.forgejo-runner}/bin/act_runner daemon --config /var/lib/gitea-runner/codeberg/config.yaml";
    };
  };
}
