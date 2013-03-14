# Configure a ceph mon
#
# == Name
#   This resource's name is the mon's id and must be numeric.
# == Parameters
# [*fsid*] The cluster's fsid.
#   Mandatory. Get one with `uuidgen -r`.
#
# [*mon_secret*] The cluster's mon's secret key.
#   Mandatory. Get one with `ceph-authtool /dev/stdout --name=mon. --gen-key`.
#
# [*auth_type*] Auth type.
#   Optional. undef or 'cephx'. Defaults to 'cephx'.
#
# [*mon_data*] Base path for mon data. Data will be put in a mon.$id folder.
#   Optional. Defaults to '/var/lib/ceph.
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
  $mon_data = '/var/lib/ceph/mon',
  $mon_port = 6789,
  $mon_addr = $ipaddress
) {

  include 'ceph::package'

  $mon_data_expanded = "${mon_data}/mon.${name}"

  #FIXME: monitor_secret will appear in "ps" output …
  exec { 'ceph-mon-keyring':
    command => "ceph-authtool /var/lib/ceph/tmp/keyring.mon.${name} \
--create-keyring \
--name=mon. \
--add-key='${monitor_secret}' \
--cap mon 'allow *'",
    creates => "/var/lib/ceph/tmp/keyring.mon.${name}",
    before  => Exec['ceph-mon-mkfs'],
    require => Package['ceph'],
  }

  exec { 'ceph-mon-mkfs':
    command => "ceph-mon --mkfs -i ${name} \
--keyring /var/lib/ceph/tmp/keyring.mon.${name}",
    creates => "${mon_data_expanded}/keyring",
    require => [Package['ceph'], Concat['/etc/ceph/ceph.conf']],
  }

  service { "ceph-mon.${name}":
    ensure  => running,
    start   => "service ceph start mon.${name}",
    stop    => "service ceph stop mon.${name}",
    status  => "service ceph status mon.${name}",
    require => Exec['ceph-mon-mkfs'],
  }

  exec { 'ceph-admin-key':
    command => "ceph-authtool /etc/ceph/keyring \
--create-keyring \
--name=client.admin \
--add-key \
$(ceph --name mon. --keyring ${mon_data_expanded}/keyring \
  auth get-or-create-key client.admin \
    mon 'allow *' \
    osd 'allow *' \
    mds allow)",
    creates => '/etc/ceph/keyring',
    require => Service["ceph-mon.${name}"],
    onlyif  => "ceph --admin-daemon /var/run/ceph/ceph-mon.${name}.asok \
mon_status|egrep -v '\"state\": \"(leader|peon)\"'",
  }

  if !empty($::ceph_admin_key) {
    @@ceph::key { 'admin':
      secret       => $::ceph_admin_key,
      keyring_path => '/etc/ceph/keyring',
    }
  }

  ceph::conf::mon { $name:
    mon_addr => $mon_addr,
  }

}
