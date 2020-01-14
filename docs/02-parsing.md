# Command Output Parsing Exercises

Despite the enhancements to deal with network devices in a programmatic way over APIs (i.e. REST, NETCONF, etc.), parsing command line output remains to be a major task when dealing with heterogeneous network environments.

CXTA provides a variety of keywords and approaches to deal with parsing, which we want to introduce in this exercise.

We again leverage the device environmnet shown earlier, and demonstrate multiple approaches on how to parse text data.

## Simple Parsing

In this test suite we show how to use simple approaches like checking for texts appearing, or extracting values from tests using Regular Expressions, a common way to parse text output.

The command output we'll parse is the same for all the test cases in the first suite: `show ip ospf neighbor` which displayes the OSPF neighbour status on one of the two routers (r1 in this case):

```
r1#show ip ospf neighbor

Neighbor ID     Pri   State           Dead Time   Address         Interface
10.0.0.2          1   FULL/DR         00:00:31    172.16.0.2      GigabitEthernet2
```

you can connect to the device (using `vagrant ssh r1` from outside the container) to check yourself. 

Please change to the 02-parsing directory (`cd ../02-parsing`, assuming you are still in the 01-basic directory from the previous test) and examine the file `02-simple.robot` (also shown below).

A few notes here:

- CXTA has evolved over time and has aggregated keywords from different sources within Cisco and externally over the years, and so some redundancy has been accumalated where the same task can be achieved using different keywords. For example the `run "show ip ospf neighbor"`  keyword on a device which has previously been selected is pretty much equivalent with the `execute command ..` keyword seen in the previous chapter.
- As robot interprets the backslash (`\`), we need to escape the backslashes used in Regular expressions (hence the `\\` seen in the expressions below)


```
# cd ../02-parsing/
# cat 02-simple.robot

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
    ${output}=  extract patterns "\\d+\.\\d+\.\\d+\.\\d+"

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
    ${output}=  extract pattern "\\d+\.\\d+\.\\d+\.\\d+\\s+\\d+\\s+([\\w]+)"
    Should be equal  ${output}   FULL

Check OSPF neighbour state using regexp parsing-2
    select device "${device}"
    run "show ip ospf neighbor"
    # instead of extracting patterns, we can verify that the output matches a pattern
    # in this example we are checking that 'FULL/' is the state
    output matches pattern "\\d+\.\\d+\.\\d+\.\\d+\\s+\\d+\\s+FULL\/.*"
    output matches pattern ".*FULL\/.*"

*** Keywords ***
Load testbed and connect to devices
    use testbed "${testbed}"
    connect to device "${device}"

```


Run this test (from within the container) and examine the log.html created.

```
root@14b56b5cc0ac:/home/devnet/cxta/02-parsing# robot 02-simple.robot
```

### Bonus Exercise: Leveraging Parameterization 

You might have noticed that we have parameterized the router name and expected router ID in the above test cases using variables. This enables us to easily adapt the test to a different envirnment: We can easily run the test on the other router (r2), and check for a different neighbor IP address (10.0.0.1) by overwriting the defined variables values on the command line using the `-v VAR:VALUE` command line arg:

```
# robot -v device:r2 -v nbr_id:10.0.0.1 02-simple.robot
```


## More Complex Parsing
