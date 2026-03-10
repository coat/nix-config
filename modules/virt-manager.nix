{pkgs, ...}: {
  # virt-manager for desktop virtualization
  programs.virt-manager.enable = true;

  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.vhostUserPackages = [pkgs.virtiofsd];

  virtualisation.spiceUSBRedirection.enable = true;
}
