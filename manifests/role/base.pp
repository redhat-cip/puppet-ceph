# ceph::role::base
#
# Base class for role-based configuration of Ceph nodes
#
# This class installs Ceph packages, and configures Ceph,
# according to global variables set either in a site manifest
# or in an External Node Classifier (ENC).
#
# It has no class parameters in order to be extensible via
# "inherits".
#
# This class understands the following global variables:
#
# ceph_release           - the Ceph release codename, like "dumpling"
#                          or "firefly" (no default)
# ceph_fsid              - the filesystem ID (no default)
# ceph_auth_type         - the authentication type (default 'cephx')
# ceph_cluster_interface - the interface to use for internal
#                          cluster communications. This class
#                          gleans the corresponding network
#                          addresses and netmasks from facts
#                          available through facter
#                          (default 'eth0')
# ceph_public_interface  - the interface to use for communications
#                          with Ceph clients (default 'eth1')
# ceph_package_ensure    - whether to just make sure the ceph
#                          package is installed ('present', default),
#                          or is the latest version available ('latest').
class ceph::role::base {

  # Style note: it looks like poor form that these variables
  # do not use the explicit top scope ("$::ceph_release" etc.),
  # but this is deliberate. While global variables and variables
  # set by an ENC are in the top scope, node variables
  # (set per node in site.pp) are not. They are in node scope
  # instead. The node scope, however, is anonymous, so it does
  # not set any explicit prefix. So to allow variables to be set
  # both globally and at the node level, use the unqualified
  # references.
  # See additional information in:
  # http://docs.puppetlabs.com/puppet/3/reference/lang_scope.html#node-scope
  $release           = $ceph_release
  $fsid              = $ceph_fsid
  $auth_type         = pick($ceph_auth_type, 'cephx')
  $public_interface  = pick($ceph_public_interface, 'eth0')
  $cluster_interface = pick($ceph_cluster_interface, 'eth1')
  $package_ensure    = pick($ceph_package_ensure, 'present')

  # This is completely silly. ceph.conf doesn't support
  # dotted-quad addresses in cluster_network and public_network,
  # and facter doesn't provide network addresses in CIDR
  # suffix format.
  # The right thing to do would be to either teach the ceph.conf
  # parser about dotted quad notation, or teach facter to expose
  # something like netmask_cidr, but until that happens, use
  # this stupid hash to look things up.
  $cidr_hash = {
    '255.0.0.0' => 8,
    '255.128.0.0' => 9,
    '255.192.0.0' => 10,
    '255.224.0.0' => 11,
    '255.240.0.0' => 12,
    '255.248.0.0' => 13,
    '255.252.0.0' => 14,
    '255.254.0.0' => 15,
    '255.255.0.0' => 16,
    '255.255.128.0' => 17,
    '255.255.192.0' => 18,
    '255.255.224.0' => 19,
    '255.255.240.0' => 20,
    '255.255.248.0' => 21,
    '255.255.252.0' => 22,
    '255.255.254.0' => 23,
    '255.255.255.0' => 24,
    '255.255.255.128' => 25,
    '255.255.255.192' => 26,
    '255.255.255.224' => 27,
    '255.255.255.240' => 28,
    '255.255.255.248' => 29,
    '255.255.255.252' => 30,
    '255.255.255.254' => 31,
    '255.255.255.255' => 32,
  }

  class { 'ceph::apt::ceph':
    release => $release,
  }

  class { 'ceph::package':
    package_ensure => $package_ensure,
  }

  class { 'ceph::conf':
    fsid            => $fsid,
    auth_type       => $auth_type,
    cluster_network => join([getvar("network_${cluster_interface}"),
                             $cidr_hash[getvar("netmask_${cluster_interface}")]],
                             "/"),
    public_network  => join([getvar("network_${public_interface}"),
                            $cidr_hash[getvar("netmask_${public_interface}")]],
                             "/"),
    require         => Class['ceph::apt::ceph']
  }

}
