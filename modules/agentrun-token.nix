# API token for the AgentRun server on crystalpalace, shared by the server
# (modules/agentrun.nix) and every machine whose CLI talks to it
# (users/sadbeast/nixos.nix, users/features/agentrun.nix).
#
# Two files of one value, since the two sides want it under different names:
# `env` is the server's EnvironmentFile (AGENTRUN_TOKEN, 32+ characters), and
# `token` is the bare value the client CLI wrapper exports as AGENTRUN_API_KEY.
# The token drives the API only: it cannot write secrets or approve tool calls
# (that takes the console password).
{pkgs, ...}: {
  clan.core.vars.generators.agentrun-token = {
    share = true;
    files.env.secret = true;
    files.token.secret = true;
    runtimeInputs = [pkgs.coreutils pkgs.openssl];
    script = ''
      token=$(openssl rand -hex 32)
      printf '%s' "$token" > "$out/token"
      echo "AGENTRUN_TOKEN=$token" > "$out/env"
    '';
  };
}
