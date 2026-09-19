{
  writeShellApplication,
  openssh,
  pass,
  coreutils,
}:
# Sign a guest's SSH public key with the pair CA so they can log into pairvm
# (microvms/pairvm.nix, TrustedUserCAKeys) without their key being committed.
# The CA private key is read from pass at $PAIR_CA_PASS_ENTRY.
writeShellApplication {
  name = "pair-invite";
  runtimeInputs = [openssh pass coreutils];
  text = ''
    usage() {
      echo "usage: pair-invite <name> <pubkey-file|-> [validity] [principal]" >&2
      echo "  validity  ssh-keygen -V interval, default +8h (e.g. +2d, +52w)" >&2
      echo "  principal account the cert is valid for, default pair" >&2
      echo "prints the certificate; send it back as <their-key>-cert.pub" >&2
      exit 2
    }
    [ $# -ge 2 ] || usage
    name=$1 pubkey=$2 validity=''${3:-+8h} principal=''${4:-pair}
    entry=''${PAIR_CA_PASS_ENTRY:-ids/ssh/pair-ca}

    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    pass show "$entry" > "$tmp/ca"
    chmod 600 "$tmp/ca"
    cat "$pubkey" > "$tmp/guest.pub"

    ssh-keygen -q -s "$tmp/ca" -I "$name" -n "$principal" -V "$validity" "$tmp/guest.pub"
    ssh-keygen -L -f "$tmp/guest-cert.pub" | grep -E 'Key ID|Principals|Valid' >&2
    cat "$tmp/guest-cert.pub"
  '';
}
