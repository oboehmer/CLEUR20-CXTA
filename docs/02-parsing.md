# Command Output Parsing Exercises

Despite the enhancements to deal with network devices in a programmatic way over APIs (i.e. REST, NETCONF, etc.), parsing command line output remains to be a major task when dealing with diverse network environments.

CXTA provides a variety of keywords and approaches to deal with parsing, which we want to introduce in this exercise.

We again leverage the device environment shown earlier, and demonstrate multiple approaches on how to parse text data.

## Simple Parsing

In this test suite we show how to use simple approaches like checking for texts appearing, or extracting values from tests using Regular Expressions, a common way to parse text output.

The command output we'll parse is the same for all the test cases in the first suite: `show ip ospf neighbor` which displays the OSPF neighbour status on one of the two routers (r1 in this case):

```
r1#show ip ospf neighbor

Neighbor ID     Pri   State           Dead Time   Address         Interface
10.0.0.2          1   FULL/DR         00:00:31    172.16.0.2      GigabitEthernet2
```

you can connect to the device (using `vagrant ssh r1` from outside the container) to check yourself. 

Please change to the 02-parsing directory (`cd ../02-parsing`, assuming you are still in the 01-basic directory from the previous test) and examine the file `02-simple.robot` (also shown below).

A few notes here:

- CXTA has evolved over time and has aggregated keywords from different sources within Cisco and externally over the years, and so some redundancy has been accumulated where the same task can be achieved using different keywords. For example the `run "show ip ospf neighbor"`  keyword on a device which has previously been selected is pretty much equivalent with the `execute command ..` keyword seen in the previous chapter.
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


Run this test (from within the container) and examine the <a href="../logs/log-02-simple.html" target="_blank">log.html</a> created.

```
root@14b56b5cc0ac:/home/devnet/cxta/02-parsing# robot 02-simple.robot
```

### Bonus Exercise: Leveraging Parameterization 

You might have noticed that we have parameterized the router name and expected router ID in the above test cases using variables. This enables us to easily adapt the test to a different environment: We can easily re-run the test on the other router (r2) and thus check for a different neighbor IP address (10.0.0.1) by overwriting the defined variables values on the command line using the `-v VAR:VALUE` command line options. Please give it a go:

```
# robot -v device:r2 -v nbr_id:10.0.0.1 02-simple.robot
```


## More Complex Parsing

Parsing text using regular expression can be cumbersome, especially if the use case requires parsing multiple values from a single command output, potentially spread across different line.

CXTA offers two approaches: TextFSM (shown below), and pyATS Genie (next chapter)

### Parsing using TextFSM

[TextFSM](https://github.com/google/textfsm/wiki/TextFSM) is a Python module that implements a template based state machine for parsing semi-formatted text. Originally developed to allow programmatic access to information given by the output of CLI driven devices, such as network routers and switches, it can however be used for any such textual output.  

CXTA has close to 1000 TextFSM templates which are able to parse a large variety of command from Cisco and 3rd party network devices, and the test user can also supply his/her own.

In one of the tests defined in _02-complex.robot_, we use a custom TextFSM file just for demo purposes, you can find it as _show_ip_ospf_neighbor.textfsm_ in the current directory:

```
Value NEIGHBOR_ID (\d+.\d+.\d+.\d+)
Value PRIORITY (\d+)
Value STATE (\S+\/\s+\-|\S+)
Value DEAD_TIME (\d+:\d+:\d+)
Value ADDRESS (\d+.\d+.\d+.\d+)
Value INTERFACE (\S+)

Start
  ^${NEIGHBOR_ID}\s+${PRIORITY}\s+${STATE}\s+${DEAD_TIME}\s+${ADDRESS}\s+${INTERFACE} -> Record
```

This template extracts values (as defined on the top of the file) for each of the lines which appear in the command output of "show ip ospf neighbor" (shared earlier), and records them in a dictionary/JSON object.

Please check the test case below, which runs and parses the "show ip ospf neighbor" output using above TextFSM template, and subsequently extracts the information based on the field names defined in the TextFSM template (i.e. NEIGHBOR_ID and NBR_STATE)

```
Check OSPF neighbour ID using TextFSM
    select device "r1"
    # runs a command and parses it through the TextFSM template provided
    # cxta includes a large collection of templates (view the 'Command Map' page in the documentation)
    # though you are able to specify your own template, as we do in this example
    run parsed "show ip ospf neighbor" with template "${CURDIR}/show_ip_ospf_neighbor.textfsm"
    # get the data from the value of 'NEIGHBOR_ID' from the dictionary that was created in the keyword above
    ${NBR_ID}=  get parsed "NEIGHBOR_ID"
    # the checks below assume that we only see a single neighbor. If multiple neighbors
    # are found, ${NBR_ID} will be a list, and we would need to iterate through the list, we
    # leave this as an exercise for the reader ;-)
    Should be Equal as Strings   ${NBR_ID}   10.0.0.2
    # another example, this time getting the neighbor state
    ${NBR_STATE}=  get parsed "STATE"
    Should Contain    ${NBR_STATE}   FULL
```

Instead of using the `get parsed` keywords, you could also collect the return value from the `run parsed ...` keyword and examine the dictionary directly. We'll get back to parsing dict/json later.

### Configuring and Retrying

The next test case also use TextFSM parsing, this time using one of CXTA's TextFSM templates (show cdp neighbor, you can view the template at /venv/lib/python3.6/site-packages/CXTA/core/commands/ios/show_cdp_neighbors.textfsm on the container).  
But to add a bit more "fun", we first configure CDP (Cisco Discovery Protocol, a simple protocol which allows you to discover \[network\] devices connected to a router), then re-run the command until a neighbour is seen (this can take up to a minute as CDP packets are not sent that frequently), before we parse it and check the host name of the neighbouring node. Finally we remove the CDP configuration to restore the test bed to its previous state (which is always a good practice):

```
*** Variables ***
${CDP_CONFIG}=          cdp run\ninterface GigabitEthernet2\ncdp enable
${REMOVE_CDP_CONFIG}   no cdp run\ninterface GigabitEthernet2\nno cdp enable
[...]


Enable CDP and check neighbor hostname using TextFSM
    [Setup]   configure "${CDP_CONFIG}" on devices "r1;r2"
    select device "r1"
    # It takes a bit for the CDP neighbor to show, so we repeat a keyword for a bit we see the relevant
    # info in the output
    set monitor interval to "15" seconds
    monitor command "show cdp neighbors" until output contains "Total cdp entries displayed : 1" or "60" seconds

    # now we have a cdp neighbor, we will run the neighbor table through the TextFSM parser
    ${output}=  run parsed "show cdp neighbors"
    # using the local interface, we can get the device id (hostname) of the neighbor
    ${HOSTNAME}=  get parsed "device_id" where "local_intf" is "Gig 2"
    Should Start With    ${HOSTNAME}   r2
    [Teardown]   configure "${REMOVE_CDP_CONFIG}" on devices "r1;r2"
```

A few things to note here:

- You see that we put the configuration and the removal of CDP into test case **Setup** and **Teardown** functions (lines 8 and 20). You have already seen the **Suite Setup** which allows us to initialize the environment prior to the first test case executed, and the Test Setup function is equivalent within the test case context, i.e. we perform an initialization before the the first test keyword runs.  
Removing the configuration in the Teardown is especially important. This ensures that the configuration is removed, no matter if any prior test step failed or not.

- We use the CXTA keyword `monitor command ...` to check the presence of a specific string. We could have also used a built-in Robot keyword [Repeat Keyword](http://robotframework.org/robotframework/latest/libraries/BuiltIn.html#Repeat%20Keyword) to repeat the execution (left as a bonus exercise).

- Finally, we use a different keyword, `get parsed ...` (#18) which again extracts values from the parsed output, but this time using an additional condition (especially practical if there was more than one neighbour).

You can find the log.html of this test execution <a href="../logs/log-02-complex.html" target="_blank">here</a>.

## Next Steps

If you still have time, we would like to share a different, and even more powerful and versatile approach on how to parse Cisco and some other devices: [Parsing with pyATS GENIE](03-genie.md)
