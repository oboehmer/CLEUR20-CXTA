*** Settings ***
Library   CXTA
Resource  cxta.robot

Suite Setup   use testbed "testbed.yaml"

*** Test Cases ***
connect r1
    connect to device "r1"

connect r2
    connect to device "r2"

check ospf adjacencies
    # if the VMs have just come up, give it a little while
    Wait Until Keyword Succeeds   5   5 sec    check "ip" neighbors on "r1"
    Wait Until Keyword Succeeds   5   5 sec    check "ipv6" neighbors on "r2"

*** Keywords ***
check "${ip}" neighbors on "${dev}"
    ${output}=   execute "show ${ip} ospf neighbor" on device "${dev}"
    Should Contain   ${output}    FULL
