*** Settings ***
Library   CXTA
Resource  cxta.robot

*** Test Cases ***
connect to all devices
    use testbed "testbed.yaml"
    @{devs}=   connect to all devices
    Set Test Message    Connected to ${devs}
