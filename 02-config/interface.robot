*** Settings ***
Library   CXTA
Resource  cxta.robot
Library   CXTA.robot.platforms.iosxr.interfaces

*** Test Cases ***
connect to all devices
    use testbed "testbed.yaml"
    connect to device "r1"
    set monitor timeout to "20" seconds
    
    configure "int GigaBitEthernet2\nshut" on device "r1"
    Wait Until Keyword Succeeds  10 times  1 second  verify interface "GigaBitEthernet2" state is "administratively down"    
 
    configure "int GigaBitEthernet2\nno shut" on device "r1"
    Wait Until Keyword Succeeds  10 times  1 second  verify interface "GigaBitEthernet2" state is "up"
