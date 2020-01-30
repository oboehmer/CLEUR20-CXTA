*** Settings ***
Library       CXTA
Resource      cxta.robot
Library       Collections       # Imports a public Robot framework library which provides the keyword "Log List" used in one of the tests
Suite Setup   Load testbed and connect to devices

*** Variables ***
${testbed}     ${CURDIR}/../testbed.yaml
${device}      r1           # Device under test
${nbr_id}      10.0.0.2     # excpected neighbour router id

*** Test Cases ***
Check OSPF neighbour state - basic output match
    # using CXTA keywords which are a bit shorter than the ones we've seen
    select device "${device}"
    run "show ip ospf neighbor"
    output contains "FULL"

Check OSPF neighbour ID using regexp parsing
    select device "${device}"
    run "show ip ospf neighbor"
    # uses a cxta keyword to find all regex pattern matches on the output from the show command above
    # the pattern will match IPv4 address, e.g. 192.168.10. All pattern matches will be saved in a list.
    # regex backslashes need to be escaped as Robot interprets them as well
    ${output}=  extract patterns "\\d+\\.\\d+\\.\\d+\\.\\d+"

    # uses a couple of keywords to log the result of the 'extract patterns' keyword - view these in the log.html
    log  ${output}
    log list  ${output}

    # check if the first element of the list is what we expect
    Should be Equal as Strings   ${output}[0]   ${nbr_id}

Check OSPF neighbour state using regexp parsing-1
    # if the whole test suite was executed, these keywords would not be needed as the output
    # would still be in the buffer from the previous test case
    select device "${device}"
    run "show ip ospf neighbor"

    # uses a longer regex pattern to retrieve the ospf state, here using anchoring to fetch
    # only the state,  ([\\w]+)
    ${output}=  extract pattern "\\d+\\.\\d+\\.\\d+\\.\\d+\\s+\\d+\\s+([\\w]+)"
    Should be equal  ${output}   FULL

Check OSPF neighbour state using regexp parsing-2
    select device "${device}"
    run "show ip ospf neighbor"
    # instead of extracting patterns, we can verify that the output matches a pattern
    # in this example we are checking that 'FULL/' is the state
    output matches pattern "\\d+\\.\\d+\\.\\d+\\.\\d+\\s+\\d+\\s+FULL\/.*"
    output matches pattern ".*FULL\/.*"

*** Keywords ***
Load testbed and connect to devices
    use testbed "${testbed}"
    connect to device "${device}"

