# LibreSCRS packages Changelog

Notable user-visible changes per release. Format follows
[Keep a Changelog](https://keepachangelog.com/) loosely.

## [Unreleased] — 1.0.0

### Added

- **A signed package repository for Debian, Ubuntu, Fedora and openSUSE.**
  `librescrs-archive-keyring` (Debian 13, Ubuntu 26.04 LTS) and
  `librescrs-release` (Fedora 43 and 44, openSUSE Tumbleweed) install the
  certificate that signs the repository together with the repository
  definition, so LibreCelik and the rest of LibreSCRS install and update with
  the system's own package manager. The repository metadata is signed, every
  RPM package is signed as well, and the APT indexes stop being accepted 30
  days after they were signed unless they are signed again.
- **One short set of commands per distribution to start.** The commands the
  website shows for adding the repository and installing LibreCelik are kept
  in this repository and tried, exactly as written, on Debian 13, Ubuntu 26.04
  LTS, Fedora 43 and 44 and openSUSE Tumbleweed before each publication of the
  repository. On Arch Linux the packages come from the AUR, after importing
  the release key; those commands are not run before publication.
