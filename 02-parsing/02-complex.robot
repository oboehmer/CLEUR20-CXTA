*** Settings ***
Library       CXTA
Resource      cxta.robot
Library       Collections       # Imports a public Robot framework library which provides the keyword "Log List" used in one of the tests
Suite Setup   Load testbed and connect to devices

*** Variables ***
${testbed}     ${CURDIR}/../testbed.yaml
${CDP_CONFIG}=          cdp run\ninterface GigabitEthernet2\ncdp enable
${REMOVE_CDP_CONFIG}   no cdp run\ninterface GigabitEthernet2\nno cdp enable

*** Test Cases ***

Check OSPF neighbour ID using TextFSM
    select device "r1"
    # runs a command and parses it through the TextFSM template provided
    # cxta includes a large collection of templates (view the 'TextFSM Map' page in the documentation)
    # though you are able to specify your own template, as we do in this example
    run parsed "show ip ospf neighbor" with template "${CURDIR}/show_ip_ospf_neighbor.textfsm"
    # get the data from the value of 'NEIGHBOR_ID' from the dictionary that was created in the keyword above
    ${NBR_ID}=  get parsed "NEIGHBOR_ID"
    # the checks below assume that we only see a single neighbor. If multiple neighbors
    # are found, ${NBR_ID} will be a list, and we would need to iterate through the list, we
    # leave this as an exercise for the reader ;-)
    Should be Equal as Strings   ${NBR_ID}   10.0.0.2
    # another example, this time getting the neighbor state
    ${NBR_STATE}=  get parsed "STATE"
    Should Contain    ${NBR_STATE}   FULL

Enable CDP and check neighbor hostname using TextFSM
    [Setup]   configure "${CDP_CONFIG}" on devices "r1;r2"
    select device "r1"
    # It takes a bit for the CDP neighbor to show, so we repeat a keyword for a bit we see the relevant
    # info in the output
    set monitor interval to "15" seconds
    monitor command "show cdp neighbors" until output contains "Total cdp entries displayed : 1" or "60" seconds

    # now we have a cdp neighbor, we will run the neighbor table through the TextFSM parser
    ${output}=  run parsed "show cdp neighbors"
    # using the local interface, we can get the device id (hostname) of the neighbor
    ${HOSTNAME}=  get parsed "device_id" where "local_intf" is "Gig 2"
    Should Start With    ${HOSTNAME}   r2
    [Teardown]   configure "${REMOVE_CDP_CONFIG}" on devices "r1;r2"

*** Keywords ***
Load testbed and connect to devices
    use testbed "${testbed}"
    use genie testbed "${testbed}"
    connect to devices "r1;r2"
