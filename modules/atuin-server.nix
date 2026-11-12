# Self-hosted Atuin sync server for sadbeast's machines
# (users/features/atuin.nix, wired up in users/sadbeast/nixos.nix). Clients
# encrypt end to end; the server stores only ciphertext. Reached by hostname
# over ZeroTier (modules/zerotier-hosts.nix), like ai-beacon.
#
# Registration stays open so the first `atuin register` works; every other
# machine joins with `atuin login` and the same key.
{
  services.atuin = {
    enable = true;
    host = "0.0.0.0";
    port = 8888;
    openFirewall = true;
    openRegistration = true;
    database.createLocally = true;
  };
}
