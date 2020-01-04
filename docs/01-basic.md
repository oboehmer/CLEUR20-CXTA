# Basic Tests

This Chapter introduces you to some basic Robotframework fundamentals and generic device interaction keywords.

## Test Execution Environment

The Robotframework and CXTA runtime environment is installed on a pre-built Container, which has been started in the [previous chapter](00-setup.md).  
The directory structure containing the scripts and tests has been mounted into the container (into /home/cisco/cxta), so you can create/edit and examine files on the Linux operating system on the host (in xxxx/DEVWKS-1407/CLEUR2020-CXTA), while the execution happens on the container.

Open an interactive session on the container using the following command:

```
docker exec -it cxta_devnet bash
```

You will end up in the _/home/cisco/cxta_ directory, and you can see all the files from the directory you started the environment from:

```
root@14b56b5cc0ac:/home/cisco/cxta# ls
01-basic    Makefile   Vagrantfile         docs        site              test-vms.robot
02-parsing  README.md  docker-compose.yml  mkdocs.yml  start-routers.sh  testbed.yaml
root@14b56b5cc0ac:/home/cisco/cxta#
```

You notice a directory `01-basic`, which contains the first test script we want to examine and execute:

## Your First Test Case

Change to the 01-basic directory and examine the 01-test1.robot file contained therein:

```
# cd 01-basic
# cat 01-test1.robot
*** Settings ***
Library   CXTA
Resource  cxta.robot

*** Variables ***
# Location of the auto-generated testbed.yaml file which contains device
# credentials. Rather than just using "../testbed.yaml", which assumes
# the execution directory is the current directory, we set it
# relative to the directory this .robot file is in (${CURDIR}), which allows
# us also to execute the test case from a different directory (for example from
# the parent directory using   robot 01-basic/)
${testbed}     ${CURDIR}/../testbed.yaml

*** Test Cases ***
Load testbed and connect to devices
    use testbed "${testbed}"
    connect to device "r1"
    connect to device "r2"

check version on r1
    ${output}=   execute "show version" on device "r1"
    Should Contain   ${output}    Cisco IOS XE Software, Version 16.09.01

check version on r2
    ${output}=   execute "show version" on device "r2"
    Should Contain   ${output}    Cisco IOS XE Software, Version 16.09.01
```

This file is a robotframework test file, and you notice different sections:

- the **Settings** section contains the libraries we want to load. For this lab, we are using the _CXTA_ library and a set of libraries which are defined in the resource file _cxta.robot_. This file is bundled with the cxta libraries on the container, you can examine it via `more /venv/lib/python3.6/site-packages/CXTA/robot/cxta.robot` if you're interested.

- The **Variables** section allows you define variables which you can use in other sections of the file. Here we only define the ${testbed} variable which contains the location of the testbed.yaml file which contains the access information to the devices we'll be interacting with.

- The final **Test Cases** section contains the actual test cases we are executing when running this file.


## Run the Test Case

Let's run it, calling it via `robot 01-test1.robot`:

```
root@14b56b5cc0ac:/home/cisco/cxta/01-basic# robot 01-test1.robot
==============================================================================
01-Test1
==============================================================================
Load testbed and connect to devices                                   | PASS |
------------------------------------------------------------------------------
check version on r1                                                   | PASS |
------------------------------------------------------------------------------
check version on r2                                                   | PASS |
------------------------------------------------------------------------------
01-Test1                                                              | PASS |
3 critical tests, 3 passed, 0 failed
3 tests total, 3 passed, 0 failed
==============================================================================
Output:  /home/cisco/cxta/01-basic/output.xml
Log:     /home/cisco/cxta/01-basic/log.html
Report:  /home/cisco/cxta/01-basic/report.html
root@14b56b5cc0ac:/home/cisco/cxta/01-basic#
```


..to be continued..