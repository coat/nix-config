{
  pkgs,
  name,
  sshKeys ? [],
  extraGroups ? [],
  enableSubIds ? false,
  ...
}: {
  users.users.${name} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = sshKeys;
    inherit extraGroups;

    subUidRanges =
      if enableSubIds
      then [
        {
          startUid = 100000;
          count = 65536;
        }
      ]
      else [];

    subGidRanges =
      if enableSubIds
      then [
        {
          startGid = 100000;
          count = 65536;
        }
      ]
      else [];
  };
}
