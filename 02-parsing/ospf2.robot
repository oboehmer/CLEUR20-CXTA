*** Settings ***
Library   Collections  # Imports a public Robot framework library called 'Collections'
Library   CXTA
Resource  cxta.robot

# the following causes a specific keyword to execute before any of the tests
# are run
Suite Setup     suite-setup

*** Variables ***

# a list with configuration commands
@{CDP_CONFIG}=   cdp run    interface GigabitEthernet2    cdp enable
@{REMOVE_CDP_CONFIG}=   no cdp run    interface GigabitEthernet2    no cdp enable

*** Test Cases ***

Get the ospf neighbour ID from R1 using TextFSM keywords
    select device "r1"
    # runs a command and parses it through the TextFSM template provided
    # cxta includes a large collection of templates (view the 'Command Map' page in the documentation
    # though you are able to specify your own template, as we do in this example
    run parsed "show ip ospf neighbor" with template "${CURDIR}/show_ip_ospf_neighbor.textfsm"
    # get the data from the value of 'NEIGHBOR_ID' from the dictionary that was created in the keyword above
    ${NBR_ID}=  get parsed "NEIGHBOR_ID"
    Should be Equal as Strings   ${NBR_ID}   10.0.0.2
    # another example, this time getting the neighbor state
    ${NBR_STATE}=  get parsed "STATE"
    Should Contain    ${NBR_STATE}   FULL

Configure CDP on both routers and get the hostname of the neighbour device
    # a cxta keyword to enable cdp globally and on the interface between the routers
    configure "${CDP_CONFIG}" on devices "r1;r2"
    select device "r1"
    # Runs a command on a 15 second interval until the output contains a specific string or the timeout is reached
    set monitor interval to "15" seconds
    monitor command "show cdp neighbors" until output contains "Total cdp entries displayed : 1" or "60" seconds
    # now we have a cdp neighbor, we will run the neighbor table through the TextFSM parser
    ${output}=  run parsed "show cdp neighbors"
    log  ${output}
    # using the local interface, we can get the device id (hostname) of the neighbor
    ${HOSTNAME}=  get parsed "device_id" where "local_intf" is "Gig 2"
    log  ${HOSTNAME}
    Should contain  ${HOSTNAME}   r2
    # remove the CDP configuration
    configure "${REMOVE_CDP_CONFIG}" on devices "r1;r2"

Get the ospf neighbor ID from R1 using Genie keywords (pyats)
    # runs a command through the genie parser
    select device "r1"
    &{json}=  parse "show ip ospf neighbor detail" on device "r1"

    ${NBR_ID}=  Get Value From Json   ${json}   $..neighbors.*.neighbor_router_id
    Should be Equal as Strings   ${NBR_ID}[0]   10.0.0.2

    ${NBR_STATE}=  Get Value From Json   ${json}   $..neighbors.*.state
    Should be Equal as Strings   ${NBR_STATE}[0]   full

Check the OSPF hello interval on a specific interface
    # we now use a keyword specified in the keyword section of this robot file
    # in the keyword the user can specify the device name and the interface
    Check if OSPF hello interval on device "r1" interface "GigabitEthernet2" is "10"


*** Keywords ***
suite-setup
    # instead of referencing "../testbed.yaml", we use full the pathname relative to
    # the directory containing the test suite (this robot file). This way we can run
    # the tests also from a different location (i.e. using "robot 01-parsing/")
    use testbed "${CURDIR}/../testbed.yaml"
    use genie testbed "${CURDIR}/../testbed.yaml"
    connect to all devices

Check if OSPF hello interval on device "${device}" interface "${interface}" is "${interval}"
    # uses a pyats keyword to learn operational information on ospf
    # the keyword runs various ospf commands as per the platforms model in genie
    ${d}=  learn "ospf" on device "r1"
    ${v}=  Get Value From Json   ${d.to_dict()}   $..interfaces.${interface}.hello_interval
    Should be equal as numbers   ${v[0]}  ${interval}