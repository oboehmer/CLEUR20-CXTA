*** Settings ***
Library       CXTA
Resource      cxta.robot
Suite Setup   Load testbed and connect to devices

*** Variables ***
${testbed}     ${CURDIR}/../testbed.yaml

*** Test Cases ***
check version on r1
    ${output}=   execute "show version" on device "r1"
    Should Contain   ${output}    Cisco IOS XE Software, Version 16.09.01

check version on r2
    ${output}=   execute "show version" on device "r2"
    Should Contain   ${output}    Cisco IOS XE Software, Version 16.09.01

*** Keywords ***
Load testbed and connect to devices
    use testbed "${testbed}"
    connect to device "r1"
    connect to device "r2"

