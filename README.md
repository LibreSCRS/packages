# LibreSCRS packages

The signed package repository for [LibreSCRS](https://librescrs.github.io/),
published at <https://librescrs.github.io/packages/>.

This repository holds no packages of its own code. It holds:

- the **keyring packages** that add the repository to a machine:
  `librescrs-archive-keyring` (Debian 13, Ubuntu 26.04 LTS) installs the
  signing certificate and an APT source that trusts it for this repository
  only; `librescrs-release` (Fedora 43 and 44, openSUSE Tumbleweed) installs
  the certificate and a dnf or zypper repository definition that checks the
  metadata and every package against it;
- **`install/`**, the first commands a user runs on each distribution. The
  website quotes these files as they are, and every publication of the
  repository runs the Debian, Ubuntu, Fedora and openSUSE ones, exactly as
  written, in a clean container of each before anything is deployed. The Arch
  commands install from the AUR and are not run there;
- the workflows that release the keyring packages and publish the repository
  from the releases of the other LibreSCRS repositories.

## Adding the repository

| Distribution | Commands |
|---|---|
| Debian 13 | [`install/debian13.txt`](install/debian13.txt) |
| Ubuntu 26.04 LTS | [`install/ubuntu2604.txt`](install/ubuntu2604.txt) |
| Fedora 43, 44 | [`install/fedora.txt`](install/fedora.txt) |
| openSUSE Tumbleweed | [`install/opensusetw.txt`](install/opensusetw.txt) |
| Arch Linux (AUR) | [`install/arch.txt`](install/arch.txt) |

## Removing the repository

On Debian and Ubuntu remove the keyring package with `purge`, not `remove`:

    sudo apt purge librescrs-archive-keyring

`apt remove` keeps `/etc/apt/sources.list.d/librescrs.sources`, a
configuration file, while it deletes the key that source names, and every
later `apt update` then fails for it. On Fedora and openSUSE, `sudo dnf remove
librescrs-release` or `sudo zypper remove librescrs-release` removes both.

## Keys

`KEYS` is the OpenPGP key that signs LibreSCRS release tags, including this
repository's. The certificate that signs the package repository is published
at <https://librescrs.github.io/packages/KEY.asc>; the keyring packages carry
the same certificate.

## Building

The keyring packages are built with the shared LibreSCRS packaging actions,
in each distribution's own container. The certificate they carry is not
committed: `packaging/ci/prepare-source.sh` takes it from LibreSCRS/ci's
`keys/` for the run's mode, so the same recipe builds a rehearsal with the
public rehearsal key and a tag with the package-signing key.

## License

LGPL-2.1-or-later. See [LICENSE](LICENSE).
