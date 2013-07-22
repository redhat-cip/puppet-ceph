# Configure a ceph client
#
# == Parameters
# [*rbd_cache*] Enable caching for librbd clients.
#   Optional. Boolean. Defaults to ceph default value (false).
#
# [*rbd_cache_size*] RBD cache size in bytes.
#   Optional. Integer. Defaults to ceph default value (32MB).
#
# [*rbd_cache_max_dirty*] The dirty limit in bytes at which the cache triggers
#    write-back. If 0, uses write-through caching.
#   Optional. Integer. Defaults to ceph default value (24MB).
#
# [*rbd_cache_target_dirty*] The dirty target before the cache begins writing
#    data to the data storage. Does not block writes to the cache. Must be less
#    than rbd_cache_max_dirty.
#   Optional. Integer. Defaults to ceph default value (16MB).
#
# [*rbd_cache_max_dirty_age*] The number of seconds dirty data is in the cache
#    before writeback starts..
#   Optional. Float. Defaults to ceph default value (1.0).
#
# [*rbd_cache_writethrough_until_flush*] Start out in write-through mode, and
#    switch to write-back after the first flush request is received. Enabling
#    this is a conservative but safe setting in case VMs running on rbd are
#    too old to send flushes, like the virtio driver in Linux before 2.6.32.
#   Optional. Boolean. Defaults to ceph default value (false).
#
# == Dependencies
#
# none
#
# == Authors
#
#  Michael Jeanson <michael.jeanson@usherbrooke.ca
#
# == Copyright
#
# Copyright 2013 Université de Sherbrooke <vrr@usherbrooke.ca>
#

class ceph::client (
  $rbd_cache                          = undef,
  $rbd_cache_size                     = undef,
  $rbd_cache_max_dirty                = undef,
  $rbd_cache_target_dirty             = undef,
  $rbd_cache_max_dirty_age            = undef,
  $rbd_cache_writethrough_until_flush = undef,

) {

  include 'ceph::package::common'
  include 'ceph::conf'
  include 'ceph::params'

  class { 'ceph::conf::client':
    rbd_cache                          => $rbd_cache,
    rbd_cache_size                     => $rbd_cache_size,
    rbd_cache_max_dirty                => $rbd_cache_max_dirty,
    rbd_cache_target_dirty             => $rbd_cache_target_dirty,
    rbd_cache_max_dirty_age            => $rbd_cache_max_dirty_age,
    rbd_cache_writethrough_until_flush => $rbd_cache_writethrough_until_flush,
  }

  Package['ceph-common'] -> Ceph::Key <<| title == 'admin' |>>
}
