*** Settings ***
Library   Collections  # Imports a public Robot framework library called 'Collections'
Library   CXTA
Resource  cxta.robot

# the following causes a specific keyword to execute before any of the tests
# are run
Suite Setup     suite-setup

*** Test Cases ***

Check ospf neighbours on R1
    select device "r1"
    run "show ip ospf neighbor"
    # a simple cxta keyword to check if the output contains a string
    Output contains "FULL"

Check ospf neighbours on R2
    # using a different way to execute and parse Output
    ${output}=   execute "show ip ospf neighbor" on device "r2"
    # we are using a builtin robot keyword, those typically use
    # tabular arguments where args need to be separated by two or more spaces
    # when using robot text files
    Should Contain    ${output}    FULL

Get the ospf neighbour ID from R1 using parsing keywords
    select device "r1"
    run "show ip ospf neighbor"
    # uses a cxta keyword to find all regex pattern matches on the output from the show command above
    # the pattern will match IPv4 address, e.g. 192.168.10. All pattern matches will be saved in a list.
    ${output}=  extract patterns "\\d+\.\\d+\.\\d+\.\\d+"
    # uses a couple of keywords to log the result of the 'extract patterns' keyword - view these in the log.html
    log  ${output}
    log list  ${output}
    # uses another builtin keyword to set the variable called 'NBR_ID' as the first item in the list.
    # in this example, the first item is the neighbor ID (lists starts from index 0)
    ${NBR_ID}=  Set Variable  ${output}[0]
    # logs the following message along with the neighbor id onto the console
    log to console  The Neighbor ID is ${NBR_ID}

Get the ospf neighbor ID state from R1
    # uses a longer regex pattern to retrieve the ospf state
    # we don't need to use the 'run' keyword again to execute the command as it was
    # the last output executed and therefore still in the buffer
    ${output}=  extract pattern "\\d+\.\\d+\.\\d+\.\\d+\\s+\\d+\\s+([\\w\/]+)"
    log to console  The OSPF neighbor has the state of "${output}"
    Should be equal  ${output}   FULL/BDR

Check the ospf neighbor ID state is FULL/BDR
    # instead of extracting patterns, we can verify that the output matches a pattern
    # in this example we are checking that 'FULL/BDR' is the state
    output matches pattern "\\d+\.\\d+\.\\d+\.\\d+\\s+\\d+\\s+FULL\/BDR"
    output matches pattern ".*FULL\/BDR"


*** Keywords ***
suite-setup
    # instead of referencing "../testbed.yaml", we use full the pathname relative to
    # the directory containing the test suite (this robot file). This way we can run
    # the tests also from a different location (i.e. using "robot 01-parsing/")
    use testbed "${CURDIR}/../testbed.yaml"
    connect to all devices

