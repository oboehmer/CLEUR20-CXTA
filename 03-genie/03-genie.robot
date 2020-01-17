
*** Settings ***
Library       CXTA
Resource      cxta.robot
#
# This test case can also run purely with publically available Cisco pyATS libraries
# Install using
#    pip install --upgrade pyats.robot genie genie.libs.robot
# uncomment the following three lines and remove the CXTA & cxta.robot on top
# Library     pyats.robot.pyATSRobot
# Library     unicon.robot.UniconRobot
# Library     genie.libs.robot.GenieRobot

Suite Setup   Load testbed and connect to devices

*** Variables ***
${testbed}     ${CURDIR}/../testbed.yaml

*** Test Cases ***

Get the ospf neighbor ID from R1 using Genie keywords (pyats)
    # runs a command through the genie parser, it returns a dictionary
    &{result}=  parse "show ip ospf neighbor detail" on device "r1"
    Log Dict   ${result}

    ${nbr_id}=  Get Value From Json   ${result}   $..neighbors.*.neighbor_router_id
    Should be Equal as Strings   ${nbr_id}[0]   10.0.0.2

    ${nbr_state}=  Get Value From Json   ${result}   $..neighbors.*.state
    Should be Equal as Strings   ${nbr_state}[0]   full

Check the OSPF hello interval on a specific interface
    # we now use a keyword specified in the keyword section of this robot file below
    # in the keyword the user can specify the device name and the interface, so the
    # very same check can be reused
    Check if OSPF hello interval on device "r1" interface "GigabitEthernet2" is "10"
    # Check if OSPF hello interval on device "r2" interface "GigabitEthernet2" is "10"

*** Keywords ***
Check if OSPF hello interval on device "${device}" interface "${interface}" is "${interval}"
    # uses a pyats keyword to learn operational information on ospf
    # the keyword runs various ospf commands as per the platforms model in genie
    ${d}=  learn "ospf" on device "${device}"
    # the learn keyword returns a python object, convert this into a dict
    ${result}=   Set Variable   ${d.to_dict()}
    Log Dict   ${result}
    ${v}=  Get Value From Json   ${result}   $..interfaces.${interface}.hello_interval
    Should be equal as numbers   ${v[0]}  ${interval}

Log Dict
    [Documentation]   Pretty-print a json/dict opject to the log
    [Arguments]    ${json}
    ${s}=   Evaluate    json.dumps($json, indent=3)    modules=json
    Log   ${s}

Load testbed and connect to devices
    # use testbed "${testbed}"
    use genie testbed "${testbed}"
    connect to devices "r1;r2"

