Name: boss
Version: 0.9.2
Release: 1
Summary: Build Orchestration Server System
Group: Productivity/Networking/Web/Utilities
License: GPL2
Source0: boss-%{version}.tar.gz
Requires: rabbitmq-server >= 1.7.2, python-boss-skynet > 0.6.0
BuildRequires:  rubygems ruby-devel
%rubygems_requires
BuildRequires:  rubygem(bundler) git gcc-c++ openssl-devel pkg-config

%description
The BOSS package configures the servers used to connect BOSS participants.
The web based viewer to provide an overview of BOSS processes is now
integrated directly into BOSS.

%prep
%setup

%build
gem build boss.gemspec
mv boss-*.gem vendor/cache/

# http://bundler.io/v1.3/man/bundle-install.1.html#DEPLOYMENT-MODE
# --deployment means "Gems are installed to vendor/bundle"
bundle install --local --standalone --deployment --binstubs=%{buildroot}/usr/bin/ --no-cache --shebang=/usr/bin/ruby

%install
mkdir -p %{buildroot}/usr/lib/boss-bundle/
cp -al vendor/bundle/. %{buildroot}/usr/lib/boss-bundle/

make DESTDIR=%{buildroot} install-rest

# Change #!/usr/local/bin/ruby to #!/usr/bin/ruby
sed -i -e 's_#!/usr/local/bin/ruby_#!/usr/bin/ruby_' $(grep -rl "usr/local/bin/ruby" %{buildroot})

%post
#!/bin/bash
#
#
# Sane defaults:
SERVER_HOME=/var/lib/boss
SERVER_LOGDIR=/var/log/boss
SERVER_DATABASE=/var/spool/boss
SERVER_USER=boss
SERVER_NAME="BOSS"
SERVER_GROUP=boss
SERVICE_DIR=/etc/service

# create user to avoid running server as root
# 1. create group if not existing
if ! getent group | grep -q "^$SERVER_GROUP:" ; then
    echo -n "Adding group $SERVER_GROUP.."
    groupadd --system $SERVER_GROUP 2>/dev/null ||true
    echo "..done"
fi
# 2. create dirs if not existing
test -d $SERVER_HOME || mkdir -p $SERVER_HOME
test -d $SERVER_DATABASE || mkdir -p $SERVER_DATABASE
test -d $SERVER_LOGDIR || mkdir -p $SERVER_LOGDIR

# 3. create user if not existing
if ! getent passwd | grep -q "^$SERVER_USER:"; then
    echo -n "Adding system user $SERVER_USER.."
    useradd --system -d $SERVER_HOME -g $SERVER_GROUP \
	$SERVER_USER 2>/dev/null || true
    echo "..done"
fi
# 4. adjust passwd entry
usermod -c "$SERVER_NAME" \
    -d $SERVER_HOME   \
    -g $SERVER_GROUP  \
    $SERVER_USER
# 5. adjust file and directory permissions
chown -R $SERVER_USER:$SERVER_GROUP $SERVER_HOME
chmod -R u=rwx,g=rxs,o= $SERVER_HOME

chown -R $SERVER_USER:$SERVER_GROUP $SERVER_LOGDIR
chmod -R u=rwx,g=rxs,o= $SERVER_LOGDIR

chown -R $SERVER_USER:$SERVER_GROUP $SERVER_DATABASE
chmod -R u=rwx,g=rwxs,o= $SERVER_DATABASE

# 6. create the boss user/vhost etc if we have rabbitmqctl

# This would be nice ... but Suse apparently thinks that just because
# you 'Require' a server you can't actually assume it's there...
#
# Maybe put it in a "first_run" or just provide INSTALL info to sysadmin?
# For now just force up the server - this is a virtual/convenience
# package afer all
echo "Starting RabbitMQ and configuring to auto-start"
systemctl enable epmd.service
systemctl enable rabbitmq-server.service
systemctl start epmd.service
systemctl start rabbitmq-server.service
if [ -e /usr/sbin/rabbitmqctl ]; then
    echo "Adding boss exchange/user and granting access"
    rabbitmqctl add_vhost boss || true
    rabbitmqctl add_user boss boss || true
    rabbitmqctl set_permissions -p boss boss '.*' '.*' '.*' || true
fi
#7. tell supervisor to pickup config and code changes
skynet apply || true
skynet reload boss || true


%pre
/usr/sbin/groupadd -r boss 2> /dev/null || :
/usr/sbin/useradd -r -o -s /bin/false -c "User for BOSS" -d /var/spool/boss -g boss boss 2> /dev/null || :
SERVICE_DIR=/etc/service
SERVER_HOME=/var/lib/boss
SNAME=boss
[ -f /etc/sysconfig/boss ] && . /etc/sysconfig/boss

if [ -e ${SERVICE_DIR}/${SNAME} ]; then
    rm ${SERVICE_DIR}/${SNAME}
fi

%postun
#don't do anything in case of upgrade
if [ ! $1 -eq 1 ] ; then
    if [ -e /usr/sbin/rabbitmqctl ]; then
      echo "Removing boss exchange/user from RabbitMQ"
      rabbitmqctl delete_vhost boss
      rabbitmqctl delete_user boss
    fi
fi

%insserv_cleanup

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%doc INSTALL README
%dir /etc/skynet
%dir /etc/supervisor
%dir /etc/supervisor/conf.d
%config(noreplace) /etc/skynet/boss.conf
%config(noreplace) /etc/supervisor/conf.d/boss.conf
/usr/bin/*
/usr/lib/boss-bundle

%package -n boss-obs-plugin
Summary: MeeGo Build Orchestration Server System
Group: Productivity/Networking/Web/Utilities
Requires: obs-server perl-Net-RabbitMQ perl-JSON-XS perl-common-sense

%description -n boss-obs-plugin
This BOSS package configures the OBS servers to connect to the BOSS engine.

%files -n boss-obs-plugin
%defattr(-,root,root,-)
/usr/lib/obs/server/plugins/notify_boss.pm
%dir /usr/lib/obs
%dir /usr/lib/obs/server
%dir /usr/lib/obs/server/plugins

%post -n boss-obs-plugin
%postun -n boss-obs-plugin


