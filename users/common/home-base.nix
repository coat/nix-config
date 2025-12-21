{
  username,
  realName,
  email,
  stateVersion ? "25.05",
  homeDirectory ? "/home/${username}",
  extraImports ? [],
}: {lib, ...}: {
  imports = [../features/global.nix] ++ extraImports;

  home = {
    inherit username homeDirectory stateVersion;
  };

  programs.git.settings.user = {
    name = realName;
    email = lib.mkDefault email;
  };
}
