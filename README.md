# mv-aws-cloudformation-coding

## Coding AWS Cloudformation stuff.


Sandbox repository to code and test new cf stuff.


## Basic workflow


When creating new stacks in my dev account generally I need:

1. Write cf code.
2. Validate cf code.
3. Create a stack with a name.
4. Update that stack many times.
5. Update that stack many times, with parameters.
6. Create the same stack, with different names.
7. Idem 4.
8. Idem 5.
9. Go back to 1.


I built a `Rakefile` with some helper tasks to accomplish that. For example


    # vpc example
    $ cd templates/vpc/
    $
    #
    # Write cf code for a 3-Az VPC
    #   file: vpc-3-az-172-18.cloudformation.json
    #   name: it will be the same as 'file'
    #
    $ file=vpc-3-az-172-18.cloudformation.json rake vt   # validate...
    $ file=vpc-3-az-172-18.cloudformation.json rake cs   # created!
    $ file=vpc-3-az-172-18.cloudformation.json rake vt   # validate...
    $ file=vpc-3-az-172-18.cloudformation.json rake us   # update.
    $ file=vpc-3-az-172-18.cloudformation.json rake vt   # validate...
    $ file=vpc-3-az-172-18.cloudformation.json rake us   # update.
    #
    # Test same template, with a new name
    #
    $ file=vpc-3-az-172-18.cloudformation.json name=vpc-v2 rake vt   # validate...
    $ file=vpc-3-az-172-18.cloudformation.json name=vpc-v2 rake cs   # created!
    $ file=vpc-3-az-172-18.cloudformation.json name=vpc-v2 rake vt   # validate...
    $ file=vpc-3-az-172-18.cloudformation.json name=vpc-v2 rake us   # update.
    $ file=vpc-3-az-172-18.cloudformation.json name=vpc-v2 rake vt   # validate...
    $ file=vpc-3-az-172-18.cloudformation.json name=vpc-v2 rake us   # update.
    #
    # Test same template, using parameters
    #
    $ file=vpc-3-az-172-18.cloudformation.json name=vpc-v2 param=p1.json rake vt   # validate...
    $ file=vpc-3-az-172-18.cloudformation.json name=vpc-v2 param=p1.json rake us   # update.
    $ file=vpc-3-az-172-18.cloudformation.json name=vpc-v2 param=p1.json rake vt   # validate...
    $ file=vpc-3-az-172-18.cloudformation.json name=vpc-v2 param=p1.json rake us   # update.


## Rake file

To see how to use the helpers:

    Usage:
    rake cs file=<file-name> name=<stack-name> [param=<param-file] [region=aws-region]
    rake us file=<file-name> name=<stack-name> [param=<param-file] [region=aws-region]
    rake vt file=<file-name>

    Or:
    file=<file-name> name=<stack-name> [param=<param-file] rake cs
    file=<file-name> name=<stack-name> [param=<param-file] rake us
    file=<file-name> name=<stack-name> [param=<param-file] rake vt

    Where:
    file-name:   AWS Cloudformation template file to be used.
    stack-name:  AWS Cloudformation stack name to be created.
                It will use <file-name> if not defined.
    param-file:  Optional: Parameter file in JSON format.
    region:      Optional: AWS region to create the stack.

    Parameter file JSON format:
    [
        { "ParameterKey": "MyName"       , "ParameterValue": "MyValue"  },
        { "ParameterKey": "KeyPairName"  , "ParameterValue": "TestKey"  },
        { "ParameterKey": "InstanceType" , "ParameterValue": "t2.micro" }
    ]


