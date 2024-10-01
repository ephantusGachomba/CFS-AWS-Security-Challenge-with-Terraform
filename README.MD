# Deploying a Secure Three-Tier AWS Architecture with Terraform
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/2ffct8vhhcz7lww4yyxb.png)

```
project-root/
├── modules/
│   ├── vpc/
│   │   ├── vpc.tf
│   │   └── outputs.tf
│   ├── ec2_webserver/
│   │   ├── launchweb.tf
│   │   ├── webserver_sg.tf
│   │   ├── variables.tf
│   │   ├── frontenddata.sh
│   │   └── outputs.tf
│   └── asg_webserver/
│   │    ├── webserverASG.tf
│   │    └── variables.tf
│   └── ec2_appserver/
│   │    ├── launchapp.tf
│   │    ├── appserver_sg.tf
│   │    ├── variables.tf
│   │    ├── backenddata.sh
│   │    └── outputs.tf
│   └── asg_appserver/
│   │    ├── appserverASG.tf
│   │    └── variables.tf
│   └── public_elb/
│   │    ├── main.tf
│   │    ├── securitygroup.tf
│   │    ├── outputs.tf
│   │    └── variables.tf
│   └── appserver_elb/
│   │    ├── main.tf
│   │    ├── securitygroup_elb.tf
│   │    ├── outputs.tf
│   │    └── variables.tf
│   └── cloudfront
│   │    ├── cloudfront.tf
│   │    ├── output.tf
│   │    └── variables.tf
│   └── cloudtrails/
│   │    ├── s3bucket_logs.tf
│   │    └── outputs.tf
├── main.tf
├── outputs.tf
└── README.md
```


[Blog Post] (https://dev.to/ephantus_gachomba_/-deploying-a-secure-three-tier-aws-architecture-with-terraform-3nfc)

Security consideration:
1. Create before destroy = True for Ec2 Instances
2. Public ELB can only be accessed via the Cloudfront only prefix_list_ids=[data.aws_ec2_managed_prefix_list.cloudfront.id]
3.- viewer protocol is redirect-to-https
-- whitelisted countries are ["US", "CA", "KE"]

## Step 1: VPC Service
- **Create VPC**
- **Create Subnets**:
    - `us-east-1a` (Public Subnet A, Private Subnet A, Private Subnet C)
    - `us-east-1b` (Public Subnet B, Private Subnet B, Private Subnet D)
- **Create Internet Gateway**
- **Create Route Table**
- **Create Route**
    - `cloudforce_rt`: `destination_cidr_block = "0.0.0.0/0"`
- **Associate Route Table to Public Subnets**: (A, B)
- **Create an Elastic IP**
- **Create a NAT Gateway in Public Subnet A and associate Elastic IP to the NAT Gateway**
- **Create a Route Table for NAT Gateway**: `destination_cidr_block = "0.0.0.0/0"`
- **Associate Route Table for NAT Gateway**: (Private Subnets:: A , B, C, D)

---

## Step 2: ec2_webserver
- **Create a launch web template`**: 
- **Create a Webserver Security Group`**: 
    - **Inbound Rules**:
    - Allow traffic from ELB in public (80 & 443)
    - **Outbound Rules**:
    - Allow all outgoing traffic to the internet
- **Output`**:
    -output launch_template_id (used by /asg_webserver module)
    -output webserver_sg (used by [/public_elb/, /appserver_elb/] modules as source for security groups)
---

## Step 3: asg_webserver module
(`webserverASG.tf`)
- **Creates the ASG for the webserver Instances**:

---

## Step 4: ec2_appserver module
- - **Create a launch app template`**: (`launchapp.tf`)
- - **Create App Server Security Group`**:(`appserver_sg.tf`)
    - **Inbound Rules**:
    - Allow traffic from ELB app server (80 & 443)
    -Allow traffic from ELB web server (80 & 443)
    - **Outbound Rules**:
    - Allow all outgoing traffic to the internet
- - **Output`**:
    -output appserver_sg (used by appserver_elb sg)
    -output launch_template_id (used by asg_appserver)

---

## Step 5: asg_appserver module
-creates an auto-scaling group (`appserverASG.tf`)
- **Create Launch Template for Application Server**: 

---

## Step 6: public_elb module
- Creates [lb, target_group, listener] (`main.tf`)
- - **Create public ELB Security Group`**:(`securitygroup_elb.tf`)
    - **Inbound Rules**:
    - Allow traffic from cloudfront only (80 & 443)
    - **Outbound Rules**:
    - Allow all outgoing traffic to the webservers
-Outputs :
    -frontendTG (used by asg_webserver)
    -elb_security_group_id(used by ec2_appserver, ec2_webserver)
    -frontend_lb_dns_name(used by cloudfront)
    -frontend_lb(used by cloudfront)

---

## Step 7: appserver_elb module
- **Create app server ELB (`main.tf`)**:
    - Load balancer type: `application`
    -lb target group( appserverTG )
    -lb listener 
- - **Create public ELB Security Group`**:(`securitygroup_elb.tf`)
    - **Inbound Rules**:
    - Allow traffic from Web instances
    - **Outbound Rules**:
    - Allow all outgoing traffic to the Internet
-Outputs :
    -appserver_elb_sg_id (used by ec2_appserver)
    -appserverTG(used by asg_appserver)

---

## Step 8: cloudfront module
--domain name = 
-- origin protocol type is http 
-- viewer protocol is redirect-to-https
-- whitelisted countries are ["US", "CA", "KE"]
-Outputs :
    -cloudfront_domain_name (shows the domain name of cloudfront on terminal )

---

## Step 9: cloudtrails modules
--create a bucket to store cloudfront trails
--Create CloudTrail to log CloudFront 

---

## Step 10: root module (main.tf)
--initialize all the modules with their sources and dependant arguments

---

## Step 11: root module (outputs.tf)
--ouput :
    -cloudfront_domain_name
    -frontend_lb_dns_name
