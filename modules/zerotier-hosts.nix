{
  config,
  lib,
  ...
}: let
  machines = builtins.attrNames (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir ../machines)
  );

  ztIpFile = name: ../vars/shared + "/zerotier-ip-${name}-zerotier/ip/value";

  # Skip ourselves so the local hostname keeps resolving via nss-myhostname
  # rather than round-tripping through the ZeroTier interface.
  peers =
    builtins.filter (
      name: name != config.networking.hostName && builtins.pathExists (ztIpFile name)
    )
    machines;

  ztIp = name: lib.removeSuffix "\n" (builtins.readFile (ztIpFile name));
in {
  networking.hosts = lib.listToAttrs (map (name: lib.nameValuePair (ztIp name) [name]) peers);
}
