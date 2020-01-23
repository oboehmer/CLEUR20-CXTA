*** Settings ***
Library       CXTA
Resource      cxta.robot

*** Variables ***
# Location of the auto-generated testbed.yaml file which contains device
# credentials. Rather than just using "../testbed.yaml", which assumes
# the execution directory is the current directory, we set it
# relative to the directory this .robot file is in (${CURDIR}), which allows
# us also to execute the test case from a different directory (for example from
# the parent directory using   robot 01-basic/)
${testbed}    ${CURDIR}/../testbed.yaml

*** Test Cases ***
Load testbed and connect to devices
    use testbed "${testbed}"
    connect to device "r1"
    connect to device "r2"

check version on r1
    ${output}=   execute "show version" on device "r1"
    Should Contain   ${output}    Cisco IOS XE Software, Version 99999999

check version on r2
    ${output}=   execute "show version" on device "r2"
    Should Contain   ${output}    Cisco IOS XE Software, Version 99999999

