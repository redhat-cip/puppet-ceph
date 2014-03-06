# ceph::role::mon
#
# Class for role-based configuration of Ceph monitor nodes
#
# This class configures a Ceph monitor (MON) node
# according to global variables set either in a site manifest
# or in an External Node Classifier (ENC).
#
# It inherits from ceph::role::base, so a node with the
# ceph::role::mon class does not necessarily also need to be
# configured with ceph::role::base.

# This class understands the global variables defined for
# ceph::role::base, plus the following:
#
# ceph_mon_secret        - the MON secret. Must be a base64 encoded
#                          secret (no default)
# ceph_mon_id            - the MON ID
#                          (default is to use the node's hostname)
#                          or "firefly" (no default)
# ceph_mon_port          - the port number to listen on
#                          (default 6789)
# ceph_mon_address       - the address to listen on
#                          (if undefined, the default is to
#                          listen on the IP address associated
#                          with ceph_public_interface, then
#                          the host's default IP address)
# ceph_cluster_interface - the interface to use for internal
#                          cluster communications. This class
#                          gleans the corresponding network
#                          addresses and netmasks from facts
#                          available through facter
#                          (default 'eth0')
# ceph_export_admin_key  - whether to export the initial client.admin key
#                          from this node (true) or not (false, default).
#                          Set this to true on only one of your MONs.
class ceph::role::mon inherits ceph::role::base {

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
  $secret       = $ceph_mon_secret
  $id           = pick($ceph_mon_id, $::hostname)
  $port         = pick($ceph_mon_port, 6789)
  $address      = pick($ceph_mon_address,
                       getvar("ipaddress_${public_interface}"),
                       $::ipaddress)
  $export_key   = str2bool(pick($ceph_export_admin_key, 'false'))

  ceph::mon { $id:
    monitor_secret => $secret,
    mon_port       => $port,
    mon_addr       => $address,
  }

  # ceph_admin_key is not a global variable, it is a facter fact
  # created by ceph_osd_bootstrap_key.rb. So, this is definitely
  # in the top scope, and the name should remain fully qualified.
  if ($export_key) {
    if !empty($::ceph_admin_key) {
      @@ceph::key { 'admin':
        secret       => $::ceph_admin_key,
        keyring_path => '/etc/ceph/keyring',
      }
    }
  }
}
