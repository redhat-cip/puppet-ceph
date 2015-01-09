$ceph_release           = 'dumpling'
$ceph_fsid              = '07d28faa-48ae-4356-a8e3-19d5b81e159e'
$ceph_mon_secret        = 'AQD7kyJQQGoOBhAAqrPAqSopSwPrrfMMomzVdw=='
$ceph_public_interface  = 'eth0'
$ceph_cluster_interface = 'eth1'
$ceph_osd_devices       = '/dev/sdb'

Exec {
  path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'
}

node 'ceph-mon0.test' {
  $ceph_export_admin_key = 'true'
  include ceph::role::mon
}

node 'ceph-mon1.test' {
  include ceph::role::mon
}

node 'ceph-mon2.test' {
  include ceph::role::mon
}

node /ceph-osd.?\.test/ {
  include ceph::role::osd
}

