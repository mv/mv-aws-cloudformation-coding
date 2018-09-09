# VPC: 3 AZs

This AWS VPC is a reference VPC using 3 availability zones for a minimal
high-availabity discussion.

This script will deliver:
* 1 VPC
* 1 Internet Gateway
* 3 AZs
* 3 NAT Gateways, 1 per AZ
* 3 Elastic IPs, 1 per NAT Gateway
* 9 Subnets, 3 per AZ: Public subnet, Private subnet, DB subnet
* 4 Route Tables: 1 Public, 3 Private
* 1 SSH Security Group, for testing purposes


The following diagram shows the architecture:

![VPC - 3AZs - Route Tables](img/vpc-3azs-route-tables.png?raw=true "VPC 3 AZs")


In this diagram the 3 AZs are:
1. Availability Zone A
2. Availability Zone B
3. Availability Zone C



## Routing: the Public subnets

Routing for the Public subnets is straight forward - all public subnets must
route through the Internet Gateway using the following route table:

    Rt-Public (Route Table Public)
    +---------------------------+
    | local     | 10.100.0.0/16 |
    | 0.0.0.0/0 | igw-id-xxxx   |
    +---------------------------+

In this example, the VPC was created with a CIDR of 10.100.0.0/16.

One route table defines the access for all public subnets in the VPC. There will
be one public subnet for each AZ.

When you consider that each AZ maps to a geographically distinct datacenter, you
will need a public subnet in that AZ so to be able to access the internet.
Because the Internet Gateway works across all AZs, only one route table will
define the access for all public subnets.

When doing the association of the public route table with each specific
public subnet, the final result should be something like:


    1. Rt-Priv-A (Route Table Subnet Private A)
       - associate to Public Subnet A
       - associate to Public Subnet B
       - associate to Public Subnet C


![VPC - 3AZs - Public](img/vpc-3azs-route-public.png?rqw=true "Public Routing")


## Routing: the Private subnets - NAT Gateways

For a private subnet access to the internet a NAT solution is being used based
on NAT Gateways.

NAT Gateways are AZ specific resources. While an Internet Gateway is a multi-AZ
resource, being able to handle traffic for all the AZs of the VPC, a NAT
resource -- either a NAT Gateway or an EC2 based gateway -- must reside in a
specific AZ inside the VPC.

Just one NAT resource is not a good solution mainly because it is a single point
of failure. If that NAT resource goes down -- either because of failure or the
need of maintenance -- all the private subnets will loose their route and access
to the internet.

Because a NAT Gateway is local to a specific AZ, each AZ will have its own NAT
Gateway with its own route table. In the diagram:


![VPC - 3AZs - Private](img/vpc-3azs-route-private.png?raw=true "Private Routing")


There are many advantages of this scenario:

* no single point of failure
* each AZ is an independent unit of routing
* there is no cross-AZ traffic to a single NAT resource
* in case of a NAT resource misconfiguration, 2 other AZs remain functional
* in case of a route table misconfiguration, 2 other AZs remain functional
* in case of an entire AZ failure, 2 other AZs remain functional


Routing for the private subnets is quite simple. Again each AZ has its own NAT
resource and VPC route table:


    Rt-Priv-A (Route Table Subnet Private A)
    +---------------------------+
    | local     | 10.100.0.0/16 |
    | 0.0.0.0/0 | nat-A-id-xxxx |
    +---------------------------+


    Rt-Priv-B (Route Table Subnet Private B)
    +---------------------------+
    | local     | 10.100.0.0/16 |
    | 0.0.0.0/0 | nat-B-id-xxxx |
    +---------------------------+


    Rt-Priv-C (Route Table Subnet Private C)
    +---------------------------+
    | local     | 10.100.0.0/16 |
    | 0.0.0.0/0 | nat-C-id-xxxx |
    +---------------------------+


When doing the association of the private route tables with each specific
private subnet, the final result should be something like:


    1. Rt-Priv-A (Route Table Subnet Private A)
       - associate to Private Subnet A
       - associate to DB Subnet A

    2. Rt-Priv-B (Route Table Subnet Private B)
       - associate to Private Subnet B
       - associate to DB Subnet B

    3. Rt-Priv-C (Route Table Subnet Private C)
       - associate to Private Subnet C
       - associate to DB Subnet C


## TODO: Adding a new Availability Zone

TODO: If you need to expand your VPC to a new Availability Zone...
TODO:
TODO: For example, now I have "Availability Zone D"
TODO:
TODO: ### Subnets
TODO:
TODO: Create Public-D, Private-D, DbSubnet-D.
TODO:
TODO: ### Public Routing
TODO:
TODO: Just add a new route table association to `Public-D`.
TODO:
TODO: ### Private Routing
TODO:
TODO: Create:
TODO: 1. 1 x Elastic IP
TODO: 2. 1 x NAT Gateway: `NAT-D`
TODO: 3. 1 x Route Table: `Rt-Priv-C`
TODO:
TODO:
TODO:     Rt-Priv-D (Route Table Subnet Private D)
TODO:     +---------------------------+
TODO:     | local     | 10.100.0.0/16 |
TODO:     | 0.0.0.0/0 | nat-D-id-xxxx |
TODO:     +---------------------------+
TODO:
TODO: 4. Associate `Rt-Priv-C` with `Private-D` and `DbSubnet-D`
TODO:
TODO:     4. Rt-Priv-D (Route Table Subnet Private D)
TODO:        - associate to Private Subnet D
TODO:        - associate to DB Subnet D
TODO:
