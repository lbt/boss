Name: boss
Version: 0.10.0
Release: 1
Summary: Build Orchestration Server System
URL: https://github.com/MeeGoIntegration/boss
Group: Productivity/Networking/Web/Utilities
License: GPL-2.0-only
Source0: boss-%{version}.tar.gz
Requires: ruby
Requires: supervisor
BuildRequires: ruby-devel
BuildRequires: rubygem(bundler)
BuildRequires: rubygem(builder)
BuildRequires: gcc-c++

Obsoletes: boss-bundle
Provides: boss-bundle

%description
The BOSS package configures the servers used to connect BOSS participants.
The web based viewer to provide an overview of BOSS processes is now
integrated directly into BOSS.

%prep
%setup

%build
make

%install
%define bundle_dir %{_libexecdir}/%{name}
make DESTDIR=%{buildroot} target=%{bundle_dir} install
%fdupes %{buildroot}%{bundle_dir}

mkdir -p %{buildroot}/etc/skynet
install -D -m 644 boss.conf %{buildroot}/etc/skynet/boss.conf
mkdir -p %{buildroot}/etc/supervisor/conf.d
install -D -m 644 supervisor_boss.conf %{buildroot}/etc/supervisor/conf.d/boss.conf

mkdir -p %{buildroot}%{_bindir}
ln -s %{bundle_dir}/bin/boss %{buildroot}%{_bindir}/boss
ln -s %{bundle_dir}/bin/boss_check_pdef %{buildroot}%{_bindir}/boss_check_pdef
ln -s %{bundle_dir}/bin/boss_clean_processes %{buildroot}%{_bindir}/boss_clean_processes

# Change #!/usr/local/bin/ruby in some gems to #!/usr/bin/ruby
# They are test scripts, but it confuses rpm auto requires
sed -i -e 's_#!/usr/local/bin/ruby_#!/usr/bin/ruby_' $(grep -rl "usr/local/bin/ruby" %{buildroot}%{bundle_dir})

%pre
getent group boss >/dev/null || groupadd -r boss
getent passwd boss >/dev/null || useradd -r -s /sbin/nologin -c "User for BOSS" -m -d /var/spool/boss -g boss boss

%files
%defattr(-,root,root,-)
%doc INSTALL README
%dir /etc/skynet
%dir /etc/supervisor
%dir /etc/supervisor/conf.d
%config(noreplace) /etc/skynet/boss.conf
%config(noreplace) /etc/supervisor/conf.d/boss.conf
%{bundle_dir}
%{_bindir}/boss
%{_bindir}/boss_check_pdef
%{_bindir}/boss_clean_processes
