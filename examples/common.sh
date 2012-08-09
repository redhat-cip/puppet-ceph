#!/bin/sh

set -x
set -e

grep -q "sid" /etc/apt/sources.list || echo "deb http://ftp2.fr.debian.org/debian/ sid main" >> /etc/apt/sources.list

aptitude update

if [ hostname | grep -q "ceph-mon0" ]; then
    aptitude install -y puppetmaster sqlite3 libsqlite3-ruby libactiverecord-ruby git augeas-tools puppet

    augtool << EOT
set /files/etc/puppet/puppet.conf/agent/pluginsync true
set /files/etc/puppet/puppet.conf/agent/server ceph-mon0.enovance.com
set /files/etc/puppet/puppet.conf/master/storeconfigs true
save
EOT

    git clone git://github.com/fcharlier/puppet-ceph.git /etc/puppet/modules/ceph
    git clone git://github.com/ripienaar/puppet-concat.git /etc/puppet/modules/concat

    service puppetmaster restart
fi
