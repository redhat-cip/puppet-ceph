class ceph::conf::client (
  $rbd_cache                          = undef,
  $rbd_cache_size                     = undef,
  $rbd_cache_max_dirty                = undef,
  $rbd_cache_target_dirty             = undef,
  $rbd_cache_max_dirty_age            = undef,
  $rbd_cache_writethrough_until_flush = undef,
) {

  concat::fragment { "ceph-client.conf":
    target  => '/etc/ceph/ceph.conf',
    order   => '90',
    content => template('ceph/ceph.conf-client.erb'),
  }

}
