# Fact: ceph_osd_bootstrap_key
#
# Purpose:
#
# Resolution:
#
# Caveats:
#

require 'facter'

## ceph_osd_bootstrap_key
## Fact that gets the ceph key "client.bootstrap-osd"

Facter.add(:ceph_admin_key) do
  setcode do
    Facter::Util::Resolution.exec("ceph auth get-key client.admin")
  end
end

## blkid_uuid_#{device} / ceph_osd_id_#{device}
## Facts that export partitions uuids & ceph osd id of device

# Load the osds/uuids from ceph
ceph_osds = Hash.new
ceph_osd_dump = Facter::Util::Resolution.exec("ceph osd dump")
if ceph_osd_dump
  ceph_osd_dump.each_line do |line|
    if line =~ /^osd\.(\d+).* ([a-f0-9\-]+)$/
      ceph_osds[$2] = $1
    end
  end
end

blkid = Facter::Util::Resolution.exec("blkid")
  blkid and blkid.each_line do |line|
  if line =~ /^\/dev\/(.+):.*UUID="([a-fA-F0-9\-]+)"/
    device_orig = $1
    uuid = $2
    device = device_orig.sub(/.*\//, "")


    Facter.add("blkid_uuid_#{device}") do
      setcode do
        uuid
      end
    end

    Facter.add("ceph_osd_id_#{device}") do
      setcode do
        ceph_osds[uuid]
      end
    end
  end
end
