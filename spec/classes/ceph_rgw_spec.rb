require 'spec_helper'

describe "ceph::rgw" do

  let :facts do
    { :concat_basedir => "/var/lib/puppet/concat" }
  end

  let :params do
    {
      :fsid         => '000000',
      :admin_secret => 'shhh_dont_tell_anyone',
      :rgw_secret   => 'shhh_my_rgw_secret',
    }
  end


 it do
    should contain_file('/var/www/s3gw.fcgi')
    should contain_file('/var/lib/ceph/radosgw')
  end

end
