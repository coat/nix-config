# PIA account credentials, shared by every host that runs a PIA tunnel
# (modules/wireguard.nix on the media server, modules/wireguard-desktop.nix).
{
  clan.core.vars.generators.pia-credentials = {
    share = true;
    files.pia-user.secret = true;
    files.pia-pass.secret = true;
    prompts.pia-user = {
      description = "PIA username (p#######)";
    };
    prompts.pia-pass = {
      description = "PIA password";
      type = "hidden";
    };
    script = ''
      cp "$prompts/pia-user" "$out/pia-user"
      cp "$prompts/pia-pass" "$out/pia-pass"
    '';
  };
}
