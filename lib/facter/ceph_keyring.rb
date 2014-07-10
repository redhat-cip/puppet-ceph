# Fact: ceph_keyring
#
# Purpose:
# Fetch client keyring (cinder, glance, ...)
#
require 'facter'
require 'json'

timeout = 10
cmd_timeout = 10

begin
  Timeout::timeout(timeout) {
    # if ceph isn't configured => Error initializing cluster client: Error
    if system("timeout #{cmd_timeout} ceph -s > /dev/null 2>&1")
      raw_auth = %x(timeout #{cmd_timeout} ceph auth list -f json)
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
  }
rescue Timeout::Error
  Facter.warnonce('ceph command timeout in ceph_keyring fact')
end
