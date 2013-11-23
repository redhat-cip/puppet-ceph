# Configure a ceph radosgw node
#
# == Name
#   This resource's name is the mon's id and must be numeric.
# == Parameters
# [*fsid*] The cluster's fsid.
#   Mandatory. Get one with `uuidgen -r`.
#
# [*admin_secret*] The admin key
#   Mandatory.
#
# [*rgw_secret*] The radosgw key
#   Mandatory.
#
# [*rgw_data*] The path where the radosgw data should be stored
#   Optional.
#
# == ToDo
#
#
# == Dependencies
#
# == Authors
#
#  Marc Koderer m.koderer@telekom.de
#
# == Copyright
#
# Copyright 2013 Deutsche Telekom AG
#


class ceph::rgw (
  $fsid,
  $admin_secret,
  $rgw_secret,
  $rgw_data  = '/var/lib/ceph/radosgw',
  $fcgi_file = '/var/www/s3gw.fcgi'
) {
  ensure_packages( [ 'radosgw', 'ceph-common', 'ceph' ] )

  file { $::ceph::rgw::rgw_data:
    ensure  => directory,
    owner   => 'root',
    group   => 0,
    mode    => '0755',
  }

  ceph::conf::rgw {$name:}

  ceph::key { 'client.admin':
    secret         => $admin_secret,
    keyring_path   => '/etc/ceph/keyring',
    require        => Package['ceph']
  }

  ceph::key { 'client.radosgw.gateway':
    secret         => $rgw_secret,
    keyring_path   => '/var/lib/ceph/radosgw/keyring.rgw',
    cap_mon        => 'allow rw',
    cap_osd        => 'allow rwx',
    inject         => true,
    inject_as_id   => 'client.admin',
    inject_keyring => '/etc/ceph/keyring',
    require        => Package['ceph']
  }

  file { $fcgi_file:
    owner   => 'root',
    mode    => '0755',
    content => '#!/bin/sh
exec /usr/bin/radosgw -c /etc/ceph/ceph.conf -n client.radosgw.gateway'
  }

  service { 'radosgw':
    ensure    => running,
    start     => '/etc/init.d/radosgw start',
    stop      => '/etc/init.d/radosgw stop',
    hasstatus => false,
    provider  => 'init',
    require   => [ Package['ceph'], Ceph::Key['client.radosgw.gateway'] ]
  }

}
