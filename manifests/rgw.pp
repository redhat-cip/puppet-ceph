# Configure a ceph radosgw node
#
# == Name
#   This resource's name is the mon's id and must be numeric.
# == Parameters
# [*fsid*] The cluster's fsid.
#   Mandatory. Get one with `uuidgen -r`.
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
  $rgw_data  = '/var/lib/ceph/radosgw',
  $fcgi_file = '/var/www/s3gw.fcgi'
) {

  include 'ceph::package'

  ensure_packages( [ 'radosgw', 'ceph-common', 'ceph' ] )

  Package['ceph'] -> Ceph::Key <<| title == 'admin' |>>

  file { $::ceph::rgw::rgw_data:
    ensure  => directory,
    owner   => 'root',
    group   => 0,
    mode    => '0755',
  }

  class { 'ceph::conf':
    fsid      => $fsid,
    auth_type => $auth_type,
  }

  ceph::conf::rgw {$name:}

  exec { 'ceph-rgw-keyring':
    command => "ceph-authtool /var/lib/ceph/radosgw/keyring.rgw \
--create-keyring \
--gen-key \
--name client.radosgw.gateway \
--cap osd 'allow rwx' \
--cap mon 'allow r'",
    creates => "/var/lib/ceph/radosgw/keyring.rgw",
    require => Package['ceph', 'ceph-common'],
  }

  exec { 'ceph-add-key':
    command => "ceph -k /etc/ceph/keyring \
auth add client.radosgw.gateway -i /var/lib/ceph/radosgw/keyring.rgw \
mon 'allow r' \
osd 'allow rwx'
",
    require => Exec['ceph-rgw-keyring'] ,
  }

  file { $fcgi_file:
    owner   => 'root',
    mode    => '0755',
    content => '#!/bin/sh
exec /usr/bin/radosgw -c /etc/ceph/ceph.conf -n client.radosgw.gateway'
  }

  # NOTE(mkoderer): seems hasstatus doesn't work with all puppet versions
  # service { 'radosgw':
  #    ensure    => running,
  #    start     => '/etc/init.d/radosgw start',
  #    stop      => '/etc/init.d/radosgw stop',
  #    hasstatus => false,
  #    pattern   => 'radosgw',
  #  }

  exec {'start_radosgw':
    command => '/etc/init.d/radosgw start',
    unless  => 'ps -ef|grep radosgw|grep -q grep',
  }

}
