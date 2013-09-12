# Fact: ceph_osd_bootstrap_key
#
# Purpose:
#
# Resolution:
#
# Caveats:
#

require 'facter'
require 'timeout'

timeout = 20

## ceph_osd_bootstrap_key
## Fact that gets the ceph key "client.bootstrap-osd"

#Facter.add(:ceph_admin_key, :timeout => timeout) do
#  setcode do
#    Facter::Util::Resolution.exec("ceph auth get-key client.admin")
#  end
#end

## blkid_uuid_#{device} / ceph_osd_id_#{device}
## Facts that export partitions uuids & ceph osd id of device

# Load the osds/uuids from ceph

begin
  Timeout::timeout(timeout) {
    ceph_osds = Hash.new
    ceph_osd_uuids = Hash.new
    ceph_osd_dump = Facter::Util::Resolution.exec("ceph osd dump | grep osd\.")
    ceph_osd_dump and ceph_osd_dump.each_line do |line|
      if line =~ /^osd\.(\d+).* ([a-f0-9\-]+)$/
        ceph_osds[$2] = $1
        ceph_osd_uuids[$1] = $2
      end
    end

    # This is only needed to workaround dmcrypted devices on boot
    ceph_conf_osds_dump = Facter::Util::Resolution.exec("ceph-conf -l osd\.")
    ceph_conf_osds_dump and ceph_conf_osds_dump.each_line do |line|
      osd_id_tmp = line.strip
      ceph_conf_osd_device = Facter::Util::Resolution.exec("ceph-conf --name #{osd_id_tmp} --lookup devs")
      if ceph_conf_osd_device and ceph_conf_osd_device.start_with?("/dev/")
        ceph_conf_osd_dev = ceph_conf_osd_device[5, ceph_conf_osd_device.length]
        ceph_conf_osd_id = osd_id_tmp[4, line.length]

        Facter.add("ceph_osd_conf_id_#{ceph_conf_osd_dev}") do
          setcode do
            ceph_conf_osd_id
          end
        end

        Facter.add("ceph_osd_conf_uuids_osd.#{ceph_conf_osd_id}") do
          setcode do
            ceph_osd_uuids[ceph_conf_osd_id]
          end
        end
      end
    end

    blkid = Facter::Util::Resolution.exec("blkid")
    blkid and blkid.each_line do |line|
      if line =~ /^\/dev\/(.+):.*UUID="([a-fA-F0-9\-]+)"/
        device = $1
        uuid = $2

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
  }
rescue Timeout::Error
  Facter.warnonce('ceph command timeout in ceph_osd_bootstrap_key fact')
end
