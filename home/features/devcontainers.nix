{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      devcontainer
      devpod
      distrobox
    ];
  };
}
