# VPC: 3 AZs

This AWS VPC is a reference VPC using 3 availability zones for a minimal
high-availabity discussion.

This script will deliver:
* 1 VPC
* 1 Internet Gateway
* 3 AZs
* 3 NAT Gateways, 1 per AZ
* 3 Elastic IPs, 1 per NAT Gateway
* 9 Subnets, 3 per AZ: Public subnet, Private subnet, DB sunet
* 4 Route Tables: 1 Public, 3 Private
* 1 SSH Security Group, for testing purposes


The following diagram shows the architecture:

[3AZs - Complete](img/vpc-3az-complete.png)


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
be on public subnet for each AZ.

When you consider that each AZ maps to a geographically distinct datacenter, you
will need a public subnet in that AZ so to be able to access the internet.
Because the Internet Gateway works across all AZs, only one route table will
define the access for all public subnets.

[3AZs - Route Public](img/3azs-route-public.png)


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


[3AZs - Route Private](img/3azs-route-private.png)

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


Rt-Priv-C (Route Table Subnet Private C)
----------------------------------------
local     | 10.100.0.0/16
0.0.0.0/0 | nat-C-id-xxxx


