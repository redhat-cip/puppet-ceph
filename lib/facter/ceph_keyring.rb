# Fact: ceph_keyring
#
# Purpose:
# Fetch client keyring (cinder, glance, ...)
#
require 'facter'
require 'json'

if system("ceph -s > /dev/null 2>&1")
  raw_auth = Facter::Util::Resolution.exec("ceph auth list -f json")
  json_auth = JSON.parse(raw_auth)
  json_auth['auth_dump'].each do |k|
    if k['entity'] =~ /client(.*)/
      if k['entity'] != 'client.admin'
        keyring = k['entity'].gsub!(/^client\./,'')
        Facter.add("ceph_keyring_#{keyring}") { setcode { k['key'] } }
      end # if !client.admin
    end # match client
  end # all entity
end # if system
