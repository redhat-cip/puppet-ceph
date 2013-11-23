# Configure and starts a ceph mon
#
# == Name
#   This resource's name is the mon's id and must be alphanumric.
#
# == Parameters
# [*mon_secret*] The cluster's mon's secret key.
#   Mandatory. Get one with `ceph-authtool --gen-print-key`.
#
# [*client_admin_secret*] The cluster's client.admin secret key.
#   Mandatory. Get one with `ceph-authtool --gen-print-key`.
#   Make sure it's the same key for all MONs on your cluster.
#
# [*mon_port*] The mon's port.
#   Optional. Defaults to 6789.
#
# [*mon_addr*] The mon's address.
#   Optional. Defaults to the $ipaddress fact.
#
# == Dependencies
#
# none
#
# == Authors
#
#  François Charlier francois.charlier@enovance.com
#
# == Copyright
#
# Copyright 2012 eNovance <licensing@enovance.com>
#
define ceph::mon (
  $monitor_secret,
  $client_admin_secret,
  $mon_port = 6789,
  $mon_addr = $ipaddress
) {

  include 'ceph::package'
  include 'ceph::conf'
  include 'ceph::params'

  $mon_data_real = regsubst($::ceph::conf::mon_data, '\$id', $name)

  ceph::conf::mon { $name:
    mon_addr => $mon_addr,
    mon_port => $mon_port,
  }

  #FIXME: monitor_secret will appear in "ps" output …
  ceph::key { 'mon.':
    secret       => $monitor_secret,
    keyring_path => "/var/lib/ceph/tmp/keyring.mon.${name}",
    cap_mon      => 'allow *',
    before       => Exec['ceph-mon-mkfs'],
    require      => Package['ceph'],
  }

  file { $mon_data_real:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    before  => Exec['ceph-mon-mkfs'],
    require => Package['ceph']
  }

  exec { 'ceph-mon-mkfs':
    command => "ceph-mon --mkfs -i ${name} --keyring /var/lib/ceph/tmp/keyring.mon.${name}",
    creates => "${mon_data_real}/keyring",
    require => [
      Package['ceph'],
      Concat['/etc/ceph/ceph.conf'],
      File[$mon_data_real]
    ],
  }

  service { "ceph-mon.${name}":
    ensure   => running,
    provider => $::ceph::params::service_provider,
    start    => "service ceph start mon.${name}",
    stop     => "service ceph stop mon.${name}",
    status   => "service ceph status mon.${name}",
    require  => Exec['ceph-mon-mkfs'],
  }

  ceph::key { 'client.admin':
    secret         => $client_admin_secret,
    keyring_path   => '/etc/ceph/keyring',
    cap_mon        => 'allow *',
    cap_osd        => 'allow *',
    cap_mds        => 'allow',
    inject         => true,
    inject_as_id   => 'mon.',
    inject_keyring => "/var/lib/ceph/tmp/keyring.mon.${name}",
    require        => [ Package['ceph'], Service["ceph-mon.${name}"] ],
  }
}
