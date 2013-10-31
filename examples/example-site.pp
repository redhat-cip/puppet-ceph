#site.pp

# 3 MON nodes
# 3 OSD nodes

node default {
    # setup some secrets needed for ceph and since we might reuse them on different
    # other nodes, let define them here.

    # puppet-secret generates values for ceph for you ...
    # https://github.com/TelekomCloud/puppet-secret.git
    $monitor_secret = secret('monitor_secret', {
                  'method' => 'ceph',
                  'secrets_mount' => 'shared-secrets',
              })
    $client_admin_secret = secret('client_admin_secret', {
                  'method' => 'ceph',
                  'secrets_mount' => 'shared-secrets',
              })
    $secret_images = secret('images', {
                  'method' => 'ceph',
                  'secrets_mount' => 'shared-secrets'
              })
    $monitor_secret_value = loadyaml('/secrets/shared/monitor_secret')
    $client_admin_secret_value = loadyaml('/secrets/shared/client_admin_secret')
    $secret_images_value = loadyaml('/secrets/shared/images')

    # As alternative use e.g. the following variables and fill it with values from 'ceph-authtool --gen-print-key':
    # $monitor_secret_value      =
    # $client_admin_secret_value =
    # $secret_images_value       =
}

######################## CEPH pseudo NODES ###########################

# CEPH conf 'node', used via inherits
node 'cephconf' inherits default {
  # fill this with your facter variables or some default values you use
  $ceph_public_net  = "${::network_eth2}/24"
  $ceph_cluster_net = "${::network_eth3}/24"

  class { 'ceph::conf':
    # define a fsid for the cluster ... 'uuid -v4'
    fsid                 => '5873e8c4-ffd1-4aa4-958b-cb98fbff5d99',
    auth_type            => 'cephx',
    pool_default_size    => '3',
    pool_default_pg_num  => '64',
    pool_default_pgp_num => '64',
    public_network       => $ceph_public_net,
    cluster_network      => $ceph_cluster_net,
    mds_activate         => false,
    osd_mount_options    => 'rw,noatime,inode64,nobootwait',
  }
}

# CEPH MON default node, used via inherits
node 'cephmon' inherits cephconf {
  ceph::mon { $::hostname:
      monitor_secret      => $monitor_secret_value,
      client_admin_secret => $client_admin_secret_value,
      mon_port            => 6789,
      # fill this with your facter variables or some default values you use
      mon_addr            => $::ipaddress_eth2,
  }
}

# CEPH OSD default node, used via inherits
node 'cephosd' inherits cephconf {

  class { 'ceph::osd':
    client_admin_secret => $client_admin_secret_value,
    # fill this with your facter variables or some default values you use
    public_address      => $::ipaddress_eth2,
    cluster_address     => $::ipaddress_eth3,
  }

  # I hope that works for you ... we use that slightly different since we use our
  # puppet-dmcrypt module here to setup crypted disks and call then ceph::osd::device
  # You can find puppet-dmcrypt here as soon as I find the time to push it:
  #  https://github.com/TelekomCloud/puppet-dmcrypt
  ceph::osd::device { '/dev/sdb':
    partition_device    => false,
  }
  ceph::osd::device { '/dev/sdc':
    partition_device    => false,
  }
  ceph::osd::device { '/dev/sdd':
    partition_device    => false,
  }

  Class['ceph::package']
    -> Class['ceph::conf']
    -> Class['ceph::osd']
}

######################## CEPH real NODES ###########################

node /cephmon1/ inherits cephmon {

  # create your pools and keys you need e.g. for OpenStack ... here as example the images pool/key

  # Generating a images pool.
  ceph::pool {'images':
    pool_name      => 'images',
    create_pool    => true,
    pg_num         => '768',
    pgp_num        => '768',
  }

  # create key for client.images and inject into cluster
  ceph::key { 'client.images':
    secret         => $secret_images_value,
    keyring_path   => '/etc/ceph/client.images.keyring',
    cap_mon        => 'allow r',
    cap_osd        => 'allow class-read object_prefix rbd_children, allow rwx pool=images',
    cap_mds        => '',
    inject         => true,
    inject_as_id   => 'mon.',
    inject_keyring => '/var/lib/ceph/mon/mon.cephmon1/keyring'
  }

  # Define order of ceph key creating, pool and setting permissions to them.
  Ceph::Mon['cephmon1']-> Ceph::Pool['images'] -> Ceph::Key['client.images']

}

node /cephmon[2-3]/ inherits cephmon {
  # NOTHING SPECIAL TO DO HERE
}

node /cephosd[1-3]/ inherits cephosd {
  # NOTHING SPECIAL TO DO HERE
}
