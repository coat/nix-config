# Shared account inside microvms/pairvm.nix. Commits made here carry this
# identity unless the repo overrides it with `git config user.*`.
{lib, ...}: {
  imports = [
    (import ../common/home-base.nix {
      username = "pair";
      realName = "Pair";
      email = "pair@pairvm";
    })
  ];

  # No private key lives in the shared account; features/global.nix's
  # keychain would complain about the missing id_ed25519 on every login.
  programs.keychain.enable = lib.mkForce false;
}
