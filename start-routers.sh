#!/bin/bash

[ -f Vagrantfile ] || ( echo "Vagrantfile not found, aborting" ; exit 1 )

trap "rm -f /tmp/sshconfig-r?.$$" EXIT

TESTBED=testbed.yaml

###############
# Bring up the VMs

vagrant up

###############
# we need some initial config to make robot happy (minimum hostname)
# while at it, also setting up connectivity on the crosslinks between the
# devices

for NUM in 1 2 ; do
    echo "Setting up r$NUM"
    cat << _EOF | vagrant ssh r$NUM
conf term
hostname r$NUM
ipv6 unicast-routing
no ip domain-lookup
default interface Loopback0
interface loopback0
 ip address 10.0.0.$NUM 255.255.255.255
 ipv6 address fd00:0:0:0::$NUM/128
 ip ospf 1 area 0
 ipv6 ospf 1 area 0
default interface GigabitEthernet2
interface GigabitEthernet2
 no shut
 ip address 172.16.0.$NUM 255.255.255.0
 ipv6 address fd00:a:a:a:2::$NUM/64
 ip ospf 1 area 0
 ipv6 ospf 1 area 0
end
write
exit
_EOF

done

###############
# Creating testbed.yaml, extracting port and identifyfile 
# created by vagrant
#
echo; echo
echo "Setting up $TESTBED"
echo "devices:" > $TESTBED
for r in r1 r2 ; do
    tmpfile=/tmp/sshconfig-${r}.$$
    vagrant ssh-config $r > $tmpfile
    port=$(sed -n 's/^ *Port  *\(.*\) *$/\1/p' $tmpfile)
    identity=$(sed -n 's/ *IdentityFile  *\(.*\) *$/\1/p' $tmpfile)
    echo "$r, port $port, IdentityFile $identity"
    cat << _EOF >> $TESTBED
  $r:
    type: router
    os: ios
    credentials:
      default:
        username: vagrant
        password: using-key
    connections:
      defaults:
        class: unicon.Unicon
      cli:
        protocol: ssh
        ip: 127.0.0.1
        port: $port
        ssh_options: -o IdentityFile=$identity -o StrictHostKeyChecking=no

_EOF

done 

# run a robot test which connects to the VMs and checks connectivity
docker run --rm -v $(pwd):/tests -w /tests dockerhub.cisco.com/cxta-docker/cxta:19.10 robot test-vms.robot