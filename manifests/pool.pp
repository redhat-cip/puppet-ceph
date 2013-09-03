# Manage some operations on the pools in the cluster
#
# == Name
# the resource name is the name of the pool to be created.
#
# == Parameters
#
# [*create_pool*] if a pool should be created
#  Optional. Boolean (true or false).
#  Defaults to 'false'.
#
# [*delete_pool*] if the given pool should be deleted.
#  WARNING: This will *PERMANENTLY DESTROY* all data stored in the pool!!!
#  Optional. Boolean (true or false).
#  Defaults to 'false'.
#
# [*increase_pg_num*] if the pg_num of a pool shoud be increased
#  Optional. Boolean (true or false).
#  Defaults to 'false'.
#
# [*increase_pgp_num*] if the pgp_num of a pool shoud be increased
#  Optional. Boolean (true or false).
#  Defaults to 'false'.
#
# [*pg_num*] Number of PGs for the pool.
#  Optional. Boolean (true or false).
#  Defaults to '128'.
#
# [*pgp_num*] Number of PGPs for the pool. 
#  Optional. Boolean (true or false).
#  Defaults to '128'.
#
# == Dependencies
#
# ceph::osd need to be called for the node beforehand. The
# MON node(s) need to be setup and running.
#
# Make sure the machine has a client.admin key in the keyring file.
#
# == Authors
#
#  Danny Al-Gaaf <danny.al-gaaf@bisect.de>
#
# == Copyright
#
#

define ceph::pool (
  $create_pool      = false,
  $delete_pool      = false,
  $increase_pg_num  = false,
  $increase_pgp_num = false,
  $pg_num           = '128',
  $pgp_num          = '128',
){
  include 'ceph::package'

  if $create_pool == true { 
    exec { "ceph-pool-create-${name}":
      command => "ceph osd pool create ${name} ${pg_num} ${pgp_num}",
      onlyif  => "ceph osd lspools | grep ' ${name},'",
      require => Package['ceph']
    }
  }

  if $delete_pool == true { 
    exec { "ceph-pool-delete-${name}":
      command => "ceph osd pool delete ${name} ${name} --yes-i-really-really-mean-it",
      unless  => "ceph osd lspools | grep ' ${name},'",
      require => Package['ceph']
    }
  }

  if $increase_pg_num == true { 
    exec { "ceph-pool-increase_pg_num-${name}":
      command => "ceph osd pool set ${name} pg_num ${pg_num}",
      unless  => "ceph osd lspools | grep ' ${name},'",
      require => Package['ceph']
    }
  }

  if $increase_pgp_num == true {
    exec { "ceph-pool-increase_pgp_num-${name}":
      # isn't ready: still creating pgs, wait
      # ready:       set pool 0 pgp_num to 512 
      # wait maximal 20 seconds to get the command pushed to the cluster!
      command   => "ceph osd pool set ${name} pgp_num $pgp_num | grep -sq 'set pool '",
      unless    => "ceph osd lspools | grep ' ${name},'",
      tries     => 10,
      try_sleep => 2,
      require   => Package['ceph']
    }
  }
}
