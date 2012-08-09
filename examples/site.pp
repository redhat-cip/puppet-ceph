
Exec {
  path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'
}

class ceph_mon (
  $id,
  $fsid
) {
  ceph::mon { $id:
    fsid => $fsid,
    monitor_secret => 'AQD7kyJQQGoOBhAAqrPAqSopSwPrrfMMomzVdw==',
    auth_type => 'cephx',
    mon_data => '/var/lib/ceph',
    mon_port => 6789,
    mon_addr => $ipaddress_eth1,
  }

  class { 'ceph::conf':
    fsid => '07d28faa-48ae-4356-a8e3-19d5b81e159e',
    auth_type => 'cephx',
  }
}

node ceph-mon0 {
  class { 'ceph_mon': id => 0, fsid => '07d28faa-48ae-4356-a8e3-19d5b81e159e' }
}

