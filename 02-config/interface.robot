*** Settings ***
Library   CXTA
Resource  cxta.robot

*** Test Cases ***
connect to all devices
    use testbed "testbed.yaml"
    connect to device "r1"
    set monitor timeout to "20" seconds
    
    configure "int GigaBitEthernet2\nshut" on device "r1"
    monitor command "show interface GigaBitEthernet2" on device "r1" until output contains "is administratively down"
    output contains "line protocol is down"
    
    configure "int GigaBitEthernet2\nno shut" on device "r1"
    monitor command "show interface GigaBitEthernet2" on device "r1" until output contains "is up"
    output contains "line protocol is up"
