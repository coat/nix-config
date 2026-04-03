{...}: {
  services.immich = {
    enable = true;
    accelerationDevices = null;
    port = 2283;
    host = "0.0.0.0";
    openFirewall = true;
    mediaLocation = "/mnt/files/immich";
  };

  users.users.immich.extraGroups = ["video" "render"];
}
