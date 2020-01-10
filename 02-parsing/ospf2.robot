*** Settings ***
Library   Collections  # Imports a public Robot framework library called 'Collections'
Library   CXTA
Resource  cxta.robot

# the following causes a specific keyword to execute before any of the tests
# are run
Suite Setup     suite-setup

*** Test Cases ***

Get the ospf neighbour ID from R1 using TextFSM keywords
    select device "r1"
    # runs a command and parses it through the TextFSM template provided
    # cxta includes a large collection of templates (view the 'Command Map' page in the documentation
    # though you are able to specify your own template, as we do in this example
    run parsed "show ip ospf neighbor" with template "02-parsing/show_ip_ospf_neighbor.textfsm"
    # get the data from the value of 'NEIGHBOR_ID' from the dictionary that was created in the keyword above
    ${NBR_ID}=  get parsed "NEIGHBOR_ID"
    log to console  The Neighbor ID is ${NBR_ID}
    # another example, this time getting the neighbor state
    ${NBR_STATE}=  get parsed "STATE"
    log to console  The Neighbor state is ${NBR_STATE}

Get the ospf neighbor ID from R1 using Genie keywords (pyats)
    select device "r1"
    # runs a command through the genie parser
    ${d}=  parse "show ip ospf neighbor detail" on device "r1"
    ${j}=  Evaluate  json.dumps($d, indent=4)   json
    ${json}=  Convert String to JSON  ${j}

    ${NBR_ID}=  Get Value From Json   ${json}   $..neighbors.*.neighbor_router_id
    log to console  The Neighbor router ID is ${NBR_ID}[0]

    ${NBR_STATE}=  Get Value From Json   ${json}   $..neighbors.*.state
    log to console  The Neighbor state is ${NBR_STATE}[0]


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
    ${l}  evaluate   json.dumps($d.to_dict(), indent=4)   json
    Log   ${l}
    ${v}=  Get Value From Json   ${d.to_dict()}   $..interfaces.${interface}.hello_interval
    Should be equal as numbers   ${v[0]}  ${interval}