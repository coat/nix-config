# Shared herdr server for pair programming. Both people SSH in as `pair` and
# attach to the same herdr session (`herdr machine add pairvm`), so keys in
# pairGuests get full control of everything the pair user can reach.
let
  sshKeys = import ../lib/ssh-keys.nix;
in {
  ipAddress = "192.168.83.3/24";
  tapId = "microvm1";
  mac = "02:00:00:00:00:02";
  workspace = "/home/sadbeast/microvm/pair";
  vsockCid = 4;
  user = "pair";
  authorizedKeys = sshKeys.sadbeast ++ sshKeys.pairGuests;
  sshProxyPort = 2222;
  # Short-lived guest access: `pair-invite <name> <pubkey> [ttl]` signs a
  # cert with the CA whose private half lives in pass (ids/ssh/pair-ca).
  userCA = ../lib/pair-ca.pub;
}
