#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Unit tests for cloud::storage::rbd::standaloneclient class
#

require 'spec_helper'

describe 'ceph::client' do

  shared_examples_for 'ceph client' do

    let :params do
      {
        :monitors => [ '10.0.0.1',
                       'host2.example.com',
                       '[fe80::288:65ff:fd36:ec52]'],
        :keys     =>
        {
          'admin' => {
            'secret'       => 'some-secret',
            'keyring_path' => '/etc/ceph/ceph.client.admin.keyring'
          },
          'user1' => {
            'secret' => 'some-other-secret'
          }
        }
      }
    end

    it 'installs the ceph-common package' do
      should contain_package('ceph-common').with_ensure('present')
    end

    it 'creates a correct configuration file' do
      should contain_file('/etc/ceph/ceph.conf').with(
        :owner   => 'root',
        :group   => '0',
        :mode    => '0644',
        :content => '[global]
mon_host = 10.0.0.1, host2.example.com, [fe80::288:65ff:fd36:ec52]

auth_supported = cephx

[client.admin]
    keyring = /etc/ceph/ceph.client.admin.keyring

[client.user1]
    keyring = /var/lib/ceph/tmp/user1.keyring

',
        :require => 'Package[ceph-common]'
      )
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'ceph client'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end
    it_configures 'ceph client'
  end

end
