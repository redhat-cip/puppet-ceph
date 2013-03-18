class ceph::key::admin (
  $export = false
) {

  include 'ceph::package'

  exec { 'ceph-admin-key':
    command  => "ceph-authtool /etc/ceph/keyring \
--create-keyring \
--name=client.admin \
--add-key \
$(ceph --name mon. --keyring ${mon_data_real}/keyring \
  auth get-or-create-key client.admin \
    mon 'allow *' \
    osd 'allow *' \
    mds allow)",
    creates  => '/etc/ceph/keyring',
    requires => Package['ceph'],
    onlyif   => "ceph --admin-daemon /var/run/ceph/ceph-mon.${name}.asok \
mon_status|egrep -v '\"state\": \"(leader|peon)\"'",
  }

  if $export {
    if !empty($::ceph_admin_key) {
      notify { "Exporting ceph admin key : ${::ceph_admin_key}" : }
      @@ceph::key { 'admin':
        secret       => $::ceph_admin_key,
        keyring_path => '/etc/ceph/keyring',
      }
    }
  }
}

