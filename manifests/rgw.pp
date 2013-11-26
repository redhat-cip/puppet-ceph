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
#   Optional. Defaults to '/var/lib/ceph/radosgw'
#
# [*fcgi_file*] The path where the fcgi file is found
#   Optional. Defaults to '/var/www/s3gw.fcgi'.
#
# [*keystone*] Wether or not to activate openstack keystone integration.
#   Optional. Defaults to false
#
# [*keystone_url*] The URL for the keystone endpoint
#   Mandatory if keystone integration is activated
#
# [*keystone_admin_token*] The keystone admin token
#   Optional. Defaults to 'admin'
#
# [*keystone_accepted_roles*] The keystone accepted roles
#   Optional. Defaults to '_member_, Member, admin, swiftoperator'
#
# [*keytone_token_cache_size*] Amount of tokens to keep in cache
#   Optional. Defaults to '10'
#
# [*keystone_revocation_interval*] Number of seconds before checking
#                                  revoked tickets
#   Optional. Defaults to '60'
#
# [*nss_db_path*] Path to the nss db
#   Optional. Defaults to '/var/lib/ceph/nss'
#
# [*debug_log*] Activates radosgw logging
#   Optional. Default is false.
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
  $rgw_data                     = '/var/lib/ceph/radosgw',
  $fcgi_file                    = '/var/www/s3gw.fcgi',
  $keystone                     = false,
  $keystone_url                 = undef,
  $keystone_admin_token         = 'admin',
  $keystone_accepted_roles      = '_member_, Member, admin, swiftoperator',
  $keystone_token_cache_size    = 10,
  $keystone_revocation_interval = 60,
  $nss_db_path                  = '/var/lib/ceph/nss',
  $debug_log                    = false
) {
  ensure_packages( [ 'radosgw', 'ceph-common', 'ceph' ] )

  if $keystone and !$keystone_url {
    fail('Keystone integration activated but keystone_url is not set')
  }

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
