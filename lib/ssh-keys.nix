let
  # Every key once, by device. The lists below pick from these.
  keys = {
    main = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGpEusv/bS34Q1JQxZXikdcwnq1vToz2d+HgV+E8NRX";
    termux = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFhHC9V56/Vy7NF9xs0zfxhg3AH/pkDr7iIFyafYpwQR termux";
    android = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB0QDSnBP4zSg8LWqvSUPyR2a2fsWBUMxQhnAOUWSKDpStz10u+F6/0h3Q/kDfSCKSps24D1UJ+ic+jcG40Hf7fJl7ynHVTfs7bvYW+vNh2d8K4Y0MlhvDwGBc8d+vJ4G+ux6eKDfysFQ6rw9aWVOGFsPEPg2sk4ga8FnP+7tPNS78o2Qq3vRwCwp6W78jIMBJhgBaSscUKKg4jbHkShuD2d8Hygq5qpeDGd1SRDksh56T4nAhoHXXw+c1BWtesq8Rezdh82Z62cCxCG5Te+uBb7MmwQFwzVRaLqopGxaZTnp8fkw9uGXR1DDOx3c8BPtyV0icvOyA0iw4MnZ2YNMV343UZb/ua/tP9DExDplcbl+Z1SBtPGGvaqI852DHSZr+ZDYkTAti26rMcGPLzjdgQPUIUawcw8CU0fDT/RgaQwaQ3LN0/ohTIIBEBJwIEp01dNlrzly77/KlpAEFcNyukm3YSNLzLgH06JsqvJHtv39y/1SII02QdIw8PlYCt/FDH+3ieFdS5XUWD+fqK7DT7+q/SZQj+9XRSZClR0DMueXx+4m68l7jaO2gyMIoLjn1rJR7wMcbTerB3mTXIQKBkFxXgDE8uObSc99NWlSJVMZE/Q== android";
    android-ps = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH4RdAvR+tb35UWiAnKnBjDxEwK2JmLGsw5SUdUAmcqS android ps";
  };
in {
  sadbeast = with keys; [main termux android android-ps];

  kent = with keys; [main termux android];

  # Guests allowed into the shared `pair` account on pairvm only
  # (microvms/pairvm.nix). Never reference this list from a host account.
  pairGuests = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPGV+vQrN5NCgyrrxF3OQ7yrdJaKRkBktV2SZ6bXQdAi"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHW1xazbQQh1zY9qE2I+MmTdfMgyPEXUvrzvNuiGgWSK"
  ];

  # Root access on every clan machine.
  primary = keys.main;
}
