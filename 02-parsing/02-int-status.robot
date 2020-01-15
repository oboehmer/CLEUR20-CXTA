*** Settings ***
Library   CXTA
Resource  cxta.robot
Suite Setup   Load testbed and connect to devices

*** Variables ***
${testbed}     ${CURDIR}/../testbed.yaml
${device}         r1

*** Test Cases ***
shutdown-with-state-check
    configure "int GigaBitEthernet2\nshut" on device "${device}"
    Wait Until Keyword Succeeds    10 times      1 second
    ...    verify interface "GigaBitEthernet2" admin state is "administratively down" on device "${device}"
    [Teardown]    configure "int GigaBitEthernet2\nno shut" on device "${device}"

*** Keywords ***
verify interface "${int}" admin state is "${state}" on device "${device}"
    select device "${device}"
    ${args}=  Create Dictionary  val=${int}
    run parsed "show_interface" "${args}"
    ${s}=  get parsed "admin_state"
    Should be Equal   ${state}    ${s}

Load testbed and connect to devices
    use testbed "${testbed}"
    connect to device "${device}"

