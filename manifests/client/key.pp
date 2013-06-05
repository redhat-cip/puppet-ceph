# Configure a ceph client keyring
#
# == Name
#   This resource's name is the ceph client key id, it must be alphanumeric.
# == Parameters
# [*owner*] System user that will own the keyring file.
#   Optionnal. Defaults to 'root'.
#
# [*group*] System group that will own the keyring file.
#   Optional. Defaults to 'root'.
#
# [*mode*] Mode of the keyring file.
#   Optional. Defaults to '0640'.
#
# == Dependencies
#
# none
#
# == Authors
#
#  Michael Jeanson <michael.jeanson@usherbrooke.ca>
#
# == Copyright
#
# Copyright 2013 Université de Sherbrooke <vrr@usherbrooke.ca>
#

define ceph::client::key (
  $owner = "root",
  $group = "root",
  $mode  = "0640",
) {

  include 'ceph::conf'
  include 'ceph::params'
  include 'ceph::client'

  ceph::conf::client::key { $name: }

  exec { 'ceph-client-${name}-key':
    command => "ceph-authtool /etc/ceph/ceph.client.${name}.keyring \
--create-keyring \
--name=client.${name} \
--add-key \
$(ceph auth get-key client.${name})",
    creates => '/etc/ceph/ceph.client.${name}.keyring',
    require => Package['ceph-common'],
  }

  file { "/etc/ceph/ceph.client.${name}.keyring":
    ensure  => file,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
  }
}
