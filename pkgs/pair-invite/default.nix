{
  writeShellApplication,
  openssh,
  pass,
  coreutils,
}:
# Grant a guest access to pairvm (microvms/pairvm.nix, TrustedUserCAKeys)
# by signing a key with the pair CA, whose private half is read from pass
# at $PAIR_CA_PASS_ENTRY. Two modes:
#   pair-invite <name> <pubkey-file|->   sign the guest's own key; prints cert
#   pair-invite <name>                   mint a throwaway keypair + cert into
#                                        ./<name>-pairvm/ and print the
#                                        commands the guest runs
writeShellApplication {
  name = "pair-invite";
  runtimeInputs = [openssh pass coreutils];
  text = ''
    usage() {
      cat >&2 <<'EOF'
    usage: pair-invite <name> [pubkey-file|-] [+validity] [principal]
      +validity  ssh-keygen -V interval, default +8h (e.g. +2d, +52w)
      principal  account the cert is valid for, default pair
    With a pubkey the certificate is printed; send it back as <their-key>-cert.pub.
    Without one a throwaway keypair is created in ./<name>-pairvm/ for the guest.
    env: PAIR_CA_PASS_ENTRY (ids/ssh/pair-ca), PAIR_TARGET (pair@cheyenne.sadbeast.com:2222)
    EOF
      exit 2
    }
    [ $# -ge 1 ] || usage
    name=$1; shift
    pubkey="" validity=+8h principal=pair
    for arg in "$@"; do
      case "$arg" in
        +*) validity=$arg ;;
        -) pubkey=- ;;
        *) if [ -z "$pubkey" ] && [ -f "$arg" ]; then pubkey=$arg; else principal=$arg; fi ;;
      esac
    done
    entry=''${PAIR_CA_PASS_ENTRY:-ids/ssh/pair-ca}
    target=''${PAIR_TARGET:-pair@cheyenne.sadbeast.com:2222}
    host=''${target##*@}; host=''${host%%:*}
    port=''${target##*:}; user=''${target%%@*}

    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    pass show "$entry" > "$tmp/ca"
    chmod 600 "$tmp/ca"

    sign() {
      ssh-keygen -q -s "$tmp/ca" -I "$name" -n "$principal" -V "$validity" "$1"
      ssh-keygen -L -f "''${1%.pub}-cert.pub" | grep -E 'Key ID|Valid' >&2
    }

    if [ -n "$pubkey" ]; then
      cat "$pubkey" > "$tmp/guest.pub"
      sign "$tmp/guest.pub"
      cat "$tmp/guest-cert.pub"
      exit 0
    fi

    dir=$name-pairvm
    mkdir -p "$dir"
    ssh-keygen -q -t ed25519 -N "" -C "$name@pairvm" -f "$dir/pairvm"
    sign "$dir/pairvm.pub"
    rm "$dir/pairvm.pub"
    cat > "$dir/README" <<EOF
    Throwaway key for pairvm, principal $principal, valid $validity.

      chmod 600 pairvm && ssh-add pairvm
      ssh -p $port $user@$host                       # sanity check
      herdr machine add ssh://$target --label pairvm
      herdr --remote ssh://$target

    Without an agent: ssh -i ./pairvm -p $port $user@$host
    EOF
    echo >&2
    echo "wrote $dir/ (pairvm, pairvm-cert.pub, README) — send over a private channel; the guest runs:" >&2
    sed 's/^/  /' "$dir/README" >&2
  '';
}
