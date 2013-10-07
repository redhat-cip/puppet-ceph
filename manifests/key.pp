# Creates a ceph keyring file
#
# == Name
#   This resource's name is the name of the key that should be generated.
#   This would be the full ceph ID name as e.g. 'client.admin' or 'mon.'.
#
# == Parameters
# [*secret*] The secret for the keyring
#   Mandatory. Get one with `ceph-authtool --gen-print-key`.
#
# [*keyring_path*] path to the keyring file.
#   Optional. Absolute file path incl. the file name.
#   Defaults to "/var/lib/ceph/tmp/${name}.keyring"
#
# [*cap_mon*] auth capabilities for MON access
#   Optional. For client.admin e.g. 'allow *'
#   Defaults to 'undef'.
#
# [*cap_osd*] auth capabilities for OSD access
#   Optional. For client.admin e.g. 'allow *'
#   Defaults to 'undef'.
#
# [*cap_mds*] auth capabilities for MDS access
#   Optional. For client.admin e.g. 'allow'
#   Defaults to 'undef'.
#
# [*user*] owner of the key file
#   Optional.
#   Defaults to 'root'
#
# [*group*] group of the key file
#   Optional.
#   Defaults to 'root'
#
# [*mode*] filebit mask for the key file
#   Optional.
#   Defaults to '0600'
#
# [*inject*] if the key should be injected into cluster
#   To inject the key into the cluster a running cluster/MON is mandatory.
#   Optional. Boolean (true or false).
#   Defaults to false.
#
# [*inject_as_id*] the ceph ID used to inject the key
#   Optional. Only needed if 'inject' was set to true, in this
#   case it's mandatory, e.g. 'client.admin' or 'mon.'
#   Defaults to 'undef'.
#
# [*inject_keyring*] path to the keyring file the key should be injected to.
#   Optional. Only needed if 'inject' was set to true, in this
#   case it's mandatory.  Absolute file path incl. the file name.
#   Defaults to 'undef'.
#
# [*add_to_config*] if the key should be added to ceph.conf
#   Adds an entry to ceph.conf with the user/client name and the path
#   to the users keyring file.
#   Optional. Defaults to false.
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
define ceph::key (
  $secret,
  $keyring_path   = "/var/lib/ceph/tmp/${name}.keyring",
  $cap_mon        = undef,
  $cap_osd        = undef,
  $cap_mds        = undef,
  $user           = 'root',
  $group          = 'root',
  $mode           = '0600',
  $inject         = false,
  $inject_as_id   = undef,
  $inject_keyring = undef,
  $add_to_config  = false,
) {

  # to concat the capability settings
  if $cap_mon {
    $mon_caps = "--cap mon '${cap_mon}' "
  }
  if $cap_osd {
    $osd_caps = "--cap osd '${cap_osd}' "
  }
  if $cap_mds {
    $mds_caps = "--cap mds '${cap_mds}' "
  }

  $concat_caps = "${mon_caps}${osd_caps}${mds_caps}"

  # generate the keyring file
  exec { "ceph-key-${name}":
    command => "ceph-authtool ${keyring_path} --create-keyring --name='${name}' --add-key='${secret}' ${concat_caps}",
    creates => $keyring_path,
    require => Package['ceph-common'],
  }

  # set the correct mask for the keyring file
  # TODO: make sure the user/group exists
  file { $keyring_path:
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => $mode,
    require => Exec["ceph-key-${name}"]
  }

  if $inject == true and $inject_as_id and $inject_keyring {
    exec { "ceph-inject-key-${name}":
      command => "ceph --name '${inject_as_id}' --keyring '${$inject_keyring}' auth add '${name}' --in-file='${keyring_path}'",
      onlyif  => "ceph --name '${inject_as_id}' --keyring '${$inject_keyring}' -s",
      require => [ Package['ceph'], File[$keyring_path] ]
    }
  }

  if $add_to_config == true {
    ceph::conf::client { $name:
      keyring => $keyring_path,
    }
  }
}
