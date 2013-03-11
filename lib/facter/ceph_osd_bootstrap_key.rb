# Fact: ceph_osd_bootstrap_key
#
# Purpose:
#
# Resolution:
#
# Caveats:
#

## ceph_osd_bootstrap_key
## Fact that gets the ceph key "client.bootstrap-osd"

require 'facter'

Facter.add(:ceph_osd_bootstrap_key) do
  setcode do
    Facter::Util::Resolution.exec("ceph auth get-key client.bootstrap-osd")
  end
end
