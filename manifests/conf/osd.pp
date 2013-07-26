define ceph::conf::osd (
  $device,
  $partition='1',
  $cluster_addr,
  $public_addr,
) {

  concat::fragment { "ceph-osd-${name}.conf":
    target  => '/etc/ceph/ceph.conf',
    order   => '80',
    content => template('ceph/ceph.conf-osd.erb'),
  }

}
