*** Settings ***
Library   CXTA
Resource  cxta.robot

# the following causes a specific keyword to execute before any of the tests
# are run
Suite Setup     suite-setup

*** Test Cases ***
check ospf neighbours on R1
    select device "r1"
    run "show ip ospf neighbor"
    Output contains "FULL"

check ospf neighbours on R2
    # using a different way to execute and parse Output
    ${output}=   execute "show ip ospf neighbor" on device "r2"
    # we are using a builtin robot keyword, those typically use
    # tabular arguments where args need to be separated by two or more spaces
    # when using robot text files
    Should Contain    ${output}    FULL

*** Keywords ***
suite-setup
    # instead of referencing "../testbed.yaml", we use full the pathname relative to
    # the directory containing the test suite (this robot file). This way we can run
    # the tests also from a different location (i.e. using "robot 01-parsing/")
    use testbed "${CURDIR}/../testbed.yaml"
    connect to all devices
