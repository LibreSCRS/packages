#!/usr/bin/env bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Runs in a work copy, on the host, before any container starts. Places the
# certificate the keyring packages carry, which the work copy (made from the
# committed tree) does not hold.
#
# The certificate is not committed: the release workflow copies the one for
# its mode from LibreSCRS/ci to packaging/keyring-cert.asc -- the public
# rehearsal key in a rehearsal, the package-signing key on a tag -- so one
# recipe builds both and names no fingerprint.
set -euo pipefail

root="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../.." && pwd)"
cert="$root/packaging/keyring-cert.asc"

[ -s "$cert" ] || { echo "prepare-source: no $cert -- place the certificate of this build's key set there first" >&2; exit 1; }
if grep -q 'PRIVATE KEY BLOCK' "$cert"; then
    echo "prepare-source: $cert holds a secret key -- only the public certificate is packaged" >&2; exit 1
fi
[ "$(grep -c '^-----BEGIN PGP PUBLIC KEY BLOCK-----$' "$cert")" = 1 ] \
    || { echo "prepare-source: $cert is not exactly one armored public key block" >&2; exit 1; }

mkdir -p packaging
command cp -f "$cert" packaging/keyring-cert.asc
echo "prepare-source: keyring certificate staged ($(wc -c <packaging/keyring-cert.asc) bytes)"
