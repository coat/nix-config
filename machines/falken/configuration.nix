{pkgs, ...}: {
  imports = [
    ../../modules/global.nix
    ../../modules/desktop.nix

    ../../users/kent/nixos.nix
  ];

  networking.hostName = "falken";

  services.xserver = {
    enable = true;

    windowManager.awesome = {
      enable = true;
      luaModules = with pkgs.luaPackages; [
        luarocks # is the package manager for Lua modules
        awesome-wm-widgets # Community collection of widgets
      ];
    };
  };

  virtualisation.vmware.guest.enable = true;

  # Fixup screen scaling in wayland for open-vm-tools
  # nixpkgs.overlays = [
  #   (self: super:
  #     with super; {
  #       open-vm-tools = open-vm-tools.overrideAttrs (old: {
  #         postFixup =
  #           old.postFixup or ""
  #           + ''
  #             l=$out/lib/open-vm-tools/plugins/vmsvc/libresolutionKMS.so
  #             old_rpath="$(patchelf --print-rpath $l)"
  #             patchelf --set-rpath "$old_rpath:${systemd}/lib:${libdrm}/lib" $l
  #             l=$out/lib/open-vm-tools/plugins/common/libvix.so
  #             old_rpath="$(patchelf --print-rpath $l)"
  #             patchelf --set-rpath "$old_rpath:${linux-pam}/lib" $l
  #           '';
  #       });
  #     })
  # ];

  # environment.etc."vmware-tools/tools.conf" = {
  #   mode = "0444";
  #   text = ''
  #     [resolutionKMS]
  #     enable=true
  #   '';
  # };

  environment.systemPackages = with pkgs; [open-vm-tools];

  # packages = with pkgs; [
  #   open-vm-tools
  # ];
}
