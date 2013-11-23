require 'spec_helper'

describe 'ceph::pool' do

  let (:title) { 'rbd_testing_pool' }

  let(:params) { { :pool_name => 'rbd_testing_pool'} }
  
  it { should include_class('ceph::package') }

  context 'when create pool' do
    let(:params) { { :pool_name => 'rbd_testing_pool', :create_pool => true, :pg_num => '128', :pgp_num => '128'} }

    it do 
      should contain_exec('ceph-pool-create-rbd_testing_pool').with({
        'command' => 'ceph osd pool create rbd_testing_pool 128 128',
        'onlyif'  => "ceph osd lspools | grep -v ' rbd_testing_pool,'",
        'require' => 'Package[ceph]'
      })
    end

  end

  context 'when delete pool' do
    let(:params) { { :pool_name => 'rbd_testing_pool', :delete_pool => true } } 

    it do
      should contain_exec('ceph-pool-delete-rbd_testing_pool').with({
        'command' => 'ceph osd pool delete rbd_testing_pool rbd_testing_pool --yes-i-really-really-mean-it',
        'onlyif'  => "ceph osd lspools | grep ' rbd_testing_pool,'",
        'require' => 'Package[ceph]'
    })
    end

  end

  context 'when increase pool pg_num' do
    let(:params) { { :pool_name => 'rbd_testing_pool', :increase_pg_num => true, :pg_num => '256' } } 

    it do
      should contain_exec('ceph-pool-increase_pg_num-rbd_testing_pool').with({
        'command' => 'ceph osd pool set rbd_testing_pool pg_num 256',
        'onlyif'  => "ceph osd lspools | grep -q ' rbd_testing_pool,' && ceph osd dump | grep rbd_testing_pool | grep -vq 'pg_num 256 '",
        'require' => 'Package[ceph]'
    })
    end

  end

  context 'when increase pool pgp_num' do
    let(:params) { { :pool_name => 'rbd_testing_pool', :increase_pgp_num => true, :pgp_num => '256' } } 

    it do
      should contain_exec('ceph-pool-increase_pgp_num-rbd_testing_pool').with({
        'command'   => "ceph osd pool set rbd_testing_pool pgp_num 256",
        'onlyif'    => "ceph osd lspools | grep -q ' rbd_testing_pool,' && ceph osd dump | grep rbd_testing_pool | grep -vq 'pgp_num 256 '",
        'tries'     => '12',
        'try_sleep' => '5',
        'require'   => 'Package[ceph]'
    })
    end

  end

end
