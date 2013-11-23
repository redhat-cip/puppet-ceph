# Configure a ceph mds
#
# == Name
#   This resource's name is the mds's id and must be numeric.
# == Parameters
# [*client_admin_secret*] The client.admin secret
#  Mandatory. The client.admin secret to generate a
#  keyring under '/etc/ceph/keyring' if needed to
#  setup and start the MDSs.

# [*mds_secret*] The cluster's mds's secret key.
#   Mandatory. Get one with `ceph-authtool --gen-print-key`.
#
# [*mds_data*] Base path for mds data. Data will be put in a mds.$id folder.
#   Optional. Defaults to '/var/lib/ceph/mds.
#
# == Dependencies
#
# none
#
# == Authors
#
#  Sébastien Han sebastien.han@enovance.com
#  François Charlier francois.charlier@enovance.com
#  David Moreau Simard dmsimard@iweb.com
#
# == Copyright
#
# Copyright 2012 eNovance <licensing@enovance.com>
#

define ceph::mds (
  $client_admin_secret,
  $mds_secret,
  $mds_data = '/var/lib/ceph/mds',
) {

  include 'ceph::conf'
  include 'ceph::package'
  include 'ceph::params'

  $mds_data_expanded = "${mds_data}/mds.${name}"

  file {
    [
    $mds_data,
    $mds_data_expanded,
    ]:
    ensure  => directory,
    owner   => 'root',
    group   => 0,
    mode    => '0755',
    before  => Ceph::Key["mds.${name}"]
  }

  ceph::key { 'client.admin':
    secret         => $client_admin_secret,
    keyring_path   => '/etc/ceph/keyring',
    require        => Package['ceph']
  }

  ceph::key { "mds.${name}":
    secret         => $mds_secret,
    keyring_path   => "${mds_data_expanded}/keyring",
    cap_mon        => 'allow rwx',
    cap_osd        => 'allow *',
    cap_mds        => 'allow *',
    inject         => true,
    inject_as_id   => 'client.admin',
    inject_keyring => '/etc/ceph/keyring',
    require        => Package['ceph']
  }

  ceph::conf::mds { $name:
    mds_data => $mds_data,
    before   => Service["ceph-mds.${name}"]
  }

  service { "ceph-mds.${name}":
    ensure   => running,
    provider => $::ceph::params::service_provider,
    start    => "service ceph start mds.${name}",
    stop     => "service ceph stop mds.${name}",
    status   => "service ceph status mds.${name}",
    require  => [ Package['ceph'], Ceph::Key["mds.${name}"] ]
  }
}
