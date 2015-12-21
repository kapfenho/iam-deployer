Removing the Application
========================

Removing the software needs those steps:

1. Shutdown running services
2. Remove database schemas
3. Remove files and directories


## Shutdown Running services

This is a manuall step. You can achive this by o proper shutdown or by
killing the application processes (but not the database processes).

This needs to be done on alle machines, in the case of a multi-host
environment.

Example: Check what processes are running and then execute the kill
command using the binary name(s):

    killall -9 java httpd.worker opmn ...


## Remove Database Schemas

There is an iam command available for this task.

Get additonal information:

    iam rcu -h

Remove database schemas (no active session allowed):

    iam rcu -a remove -t { identity | access | analytics | bip }

The schemas to remove are identified by the database config in the file

    user-config/iam.config


## Remove Files and Directories

There is an iam command available for this task.

    iam remove -h
    # e.g.
    iam remove -t all

You can call the command with the option -A for executing it on all 
machines or using -H host_name for running it on a certain host.


## Remove Environment Settings

The environment is kept in this directories in $HOME:

    ~/bin
    ~/lib
    ~/.env
    ~/.creds

Additional sourcing is done in

    ~/.bash_profile

You can either remove the directories recursively or call

    iam remove -t env

Important: you need to logout and get a fresh session after this change.

