# Add new mon in a cluster
#
define ceph::add_mon (
  $mon_id,
  $mon_addr,
  $mon_port,
  $local_mon_port,
  $local_mon_addr,
) {

  # TODO improve with a unless statement
  exec { "ceph-add-mon-${mon_id}":
    command => "ceph -m ${local_mon_addr}:${local_mon_port} mon add ${mon_id} ${mon_addr}:${mon_port}",
    #unless => something,
    require => Exec['ceph-mon-mkfs'],
  }

}
