Name:           librescrs-release
Version:        1.0.0
Release:        1%{?dist}
Summary:        LibreSCRS package repository: signing key and repository definition

License:        LGPL-2.1-or-later
URL:            https://github.com/LibreSCRS/packages
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch

# install(1), in %%install. Named because the Tumbleweed image resolves build
# dependencies from this list alone.
BuildRequires:  coreutils

# One recipe, built in each distribution's own image: zypper and dnf read
# their repository definitions from different directories.
%if 0%{?suse_version}
%global repodir %{_sysconfdir}/zypp/repos.d
%else
%global repodir %{_sysconfdir}/yum.repos.d
%endif

%description
Installs the certificate that signs the LibreSCRS package repository and the
repository definition that names it, so LibreCelik and the rest of LibreSCRS
install and update with the system's package manager. Both the repository
metadata and every package are checked against that certificate.

%prep
%setup -q

%build
# packaging/keyring-cert.asc is placed and checked by packaging/ci/prepare-source.sh.

# No %%post importing the key: rpm cannot take its transaction lock from a
# scriptlet, and the import fails while the transaction still reports
# success. dnf imports the key from gpgkey= on first use; zypper asks the
# administrator, who has already imported it by hand on Tumbleweed.
%install
install -Dpm 0644 packaging/keyring-cert.asc %{buildroot}%{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-librescrs
install -d %{buildroot}%{repodir}
%if 0%{?suse_version}
cat >%{buildroot}%{repodir}/librescrs.repo <<'REPO'
[librescrs]
name=LibreSCRS
baseurl=https://librescrs.github.io/packages/rpm/opensusetw/
type=rpm-md
enabled=1
autorefresh=1
gpgcheck=1
repo_gpgcheck=1
pkg_gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-librescrs
metadata_expire=6h
REPO
%else
# skip_if_unavailable: on the day a new Fedora is released the repository has
# no tree for it yet, and an unreachable repository must not stop every other
# update on the machine.
cat >%{buildroot}%{repodir}/librescrs.repo <<'REPO'
[librescrs]
name=LibreSCRS
baseurl=https://librescrs.github.io/packages/rpm/fedora$releasever/
enabled=1
gpgcheck=1
repo_gpgcheck=1
pkg_gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-librescrs
metadata_expire=6h
skip_if_unavailable=True
REPO
%endif

%files
%license LICENSE
%if 0%{?suse_version}
# No base package owns it on openSUSE.
%dir %{_sysconfdir}/pki/rpm-gpg
%endif
%{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-librescrs
%config(noreplace) %{repodir}/librescrs.repo

%changelog
* Sat Oct 17 2026 LibreSCRS <librescrs@proton.me> - 1.0.0-1
- First release: the LibreSCRS repository definition and its signing key.
