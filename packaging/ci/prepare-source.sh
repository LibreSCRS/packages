#!/usr/bin/env bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Runs in a work copy, on the host, before any container starts. Places the
# certificate the keyring packages carry at packaging/keyring-cert.asc, the
# one path both recipes read. It is never committed: it is the certificate of
# the run's key set, taken from LibreSCRS/ci's keys/ (its one home), so one
# recipe builds both and names no fingerprint.
#
#   KEYRING_MODE      rehearse -> keys/rehearsal.asc (the public rehearsal key:
#                     the publisher's rehearsal then installs these packages
#                     exactly as a user would); publish -> keys/package-signing.asc
#   KEYRING_KEYS_DIR  a LibreSCRS/ci checkout's keys/ directory, absolute
#
# This is the only check of the certificate: exactly one certificate, public
# only. Anything around the armored block is dropped, so neither package
# carries text nobody looked at.
set -euo pipefail

case "${KEYRING_MODE:-}" in
    rehearse) keyset=rehearsal ;;
    publish)  keyset=package-signing ;;
    *) echo "prepare-source: KEYRING_MODE is '${KEYRING_MODE:-}' -- want rehearse or publish" >&2; exit 1 ;;
esac
cert="${KEYRING_KEYS_DIR:-}/$keyset.asc"
[ -n "${KEYRING_KEYS_DIR:-}" ] && [ -s "$cert" ] \
    || { echo "prepare-source: no certificate '$cert' (KEYRING_KEYS_DIR names a LibreSCRS/ci keys/ directory)" >&2; exit 1; }

GNUPGHOME="$(mktemp -d "${TMPDIR:-/var/tmp}/lg.XXXXXX")"
export GNUPGHOME
trap 'gpgconf --kill all >/dev/null 2>&1; rm -rf "$GNUPGHOME"' EXIT
listing="$(gpg --batch --with-colons --show-keys "$cert" 2>/dev/null)" \
    || { echo "prepare-source: $cert is not an OpenPGP certificate gpg can read" >&2; exit 1; }
pubs="$(grep -c '^pub:' <<<"$listing" || true)"
secs="$(grep -c '^sec:' <<<"$listing" || true)"
[ "$secs" = 0 ] || { echo "prepare-source: $cert holds a secret key -- only the public certificate is packaged" >&2; exit 1; }
[ "$pubs" = 1 ] || { echo "prepare-source: $cert holds $pubs certificates -- want exactly one" >&2; exit 1; }

mkdir -p packaging
sed -n '/^-----BEGIN PGP PUBLIC KEY BLOCK-----$/,/^-----END PGP PUBLIC KEY BLOCK-----$/p' "$cert" >packaging/keyring-cert.asc
[ "$(grep -c '^-----BEGIN PGP PUBLIC KEY BLOCK-----$' packaging/keyring-cert.asc)" = 1 ] \
    || { echo "prepare-source: $cert is not one armored public key block" >&2; exit 1; }
fpr="$(awk -F: '$1=="fpr"{print $10; exit}' <<<"$listing")"
echo "prepare-source: keyring certificate $keyset ($fpr) staged"
