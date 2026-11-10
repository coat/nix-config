# Agent bearer token for the ai-beacon dashboard on crystalpalace, shared by the
# server (modules/ai-beacon.nix) and every machine whose agents report to it
# (users/sadbeast/nixos.nix).
#
# One env-format file serves both sides: systemd loads it as an
# EnvironmentFile, and the HM activation (users/features/ai-beacon.nix) sources
# it for `ai-beacon install`.
{pkgs, ...}: {
  clan.core.vars.generators.ai-beacon-token = {
    share = true;
    files.env.secret = true;
    runtimeInputs = [pkgs.coreutils pkgs.openssl];
    script = ''
      echo "AI_BEACON_AUTH_TOKEN=$(openssl rand -hex 32)" > "$out/env"
    '';
  };
}
