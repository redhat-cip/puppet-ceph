# Define a mds
#
define ceph::conf::mds (
  $mds_data,
  $config = {},
) {
  validate_hash($config)

  @@concat::fragment { "ceph-mds-${name}.conf":
    target  => '/etc/ceph/ceph.conf',
    order   => '60',
    content => template('ceph/ceph.conf-mds.erb'),
  }

}
