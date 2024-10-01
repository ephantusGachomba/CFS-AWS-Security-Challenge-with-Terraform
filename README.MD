# Deploying a Secure Three-Tier AWS Architecture with Terraform

![Architecture Diagram](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/2ffct8vhhcz7lww4yyxb.png)


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

[Blog Post](https://dev.to/ephantus_gachomba_/-deploying-a-secure-three-tier-aws-architecture-with-terraform-3nfc)

## Security Considerations
1. **Create Before Destroy** = `true` for EC2 Instances:
    - This ensures that new EC2 instances are created before terminating the old ones, minimizing downtime and ensuring availability during updates or changes.
   
2. **Public ELB can only be accessed via CloudFront**:
    ```hcl
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
    ```
    - This restricts direct access to the Application Load Balancer (ALB), allowing only CloudFront to forward traffic, which enhances security by adding another layer of control and filtering malicious traffic.

3. **Viewer Protocol** is `redirect-to-https`:
    - This setting forces HTTP requests to be redirected to HTTPS, ensuring all traffic is encrypted in transit for better security, particularly for sensitive data or login sessions.

4. **Whitelisted Countries**: `["US", "CA", "KE"]`:
    - By specifying allowed countries, only requests originating from the listed regions (United States, Canada, Kenya) can access the application, providing geo-based access control to mitigate security risks.

5. **CloudTrail for Logging**:
    - AWS CloudTrail is enabled to log API calls and user activities across your AWS environment, allowing you to track changes and detect potential security threats or compliance issues. Logs can be stored securely in an S3 bucket for audit and analysis.


---

## Step 1: VPC Service
- **Create VPC**
- **Create Subnets**:
    - `us-east-1a`: (Public Subnet A, Private Subnet A, Private Subnet C)
    - `us-east-1b`: (Public Subnet B, Private Subnet B, Private Subnet D)
- **Create Internet Gateway**
- **Create Route Table**
    - **Route**:
      ```hcl
      cloudforce_rt: destination_cidr_block = "0.0.0.0/0"
      ```
- **Associate Route Table to Public Subnets**: (A, B)
- **Create an Elastic IP**
- **Create a NAT Gateway in Public Subnet A and associate it with the Elastic IP**
- **Create a Route Table for NAT Gateway**:
    ```hcl
    destination_cidr_block = "0.0.0.0/0"
    ```
- **Associate Route Table for NAT Gateway**: (Private Subnets: A, B, C, D)

---

## Step 2: EC2 Webserver
- **Create a Launch Web Template**
- **Create a Webserver Security Group**:
    - **Inbound Rules**:
        - Allow traffic from ELB in public (ports 80 & 443).
    - **Outbound Rules**:
        - Allow all outgoing traffic to the internet.
- **Outputs**:
    - `launch_template_id` (used by `/asg_webserver` module).
    - `webserver_sg` (used by `/public_elb/`, `/appserver_elb/` modules as source for security groups).

---

## Step 3: ASG Webserver Module
- **Creates the Auto Scaling Group (ASG) for the Webserver Instances**.

---

## Step 4: EC2 Appserver Module
- **Create a Launch App Template**: (`launchapp.tf`)
- **Create App Server Security Group**: (`appserver_sg.tf`)
    - **Inbound Rules**:
        - Allow traffic from ELB (80 & 443).
        - Allow traffic from the web server (80 & 443).
    - **Outbound Rules**:
        - Allow all outgoing traffic to the internet.
- **Outputs**:
    - `appserver_sg` (used by `appserver_elb_sg`).
    - `launch_template_id` (used by `asg_appserver`).

---

## Step 5: ASG Appserver Module
- **Creates the Auto Scaling Group for the Application Server**.

---

## Step 6: Public ELB Module
- **Creates Load Balancer, Target Group, Listener**: (`main.tf`)
- **Create Public ELB Security Group**: (`securitygroup_elb.tf`)
    - **Inbound Rules**:
        - Allow traffic from CloudFront only (ports 80 & 443).
    - **Outbound Rules**:
        - Allow all outgoing traffic to the web servers.
- **Outputs**:
    - `frontendTG` (used by `asg_webserver`).
    - `elb_security_group_id` (used by `ec2_appserver`, `ec2_webserver`).
    - `frontend_lb_dns_name` (used by CloudFront).
    - `frontend_lb` (used by CloudFront).

---

## Step 7: Appserver ELB Module
- **Create Application Load Balancer**: (`main.tf`)
    - Load balancer type: `application`.
- **Create App Server ELB Security Group**: (`securitygroup_elb.tf`)
    - **Inbound Rules**:
        - Allow traffic from Web Instances.
    - **Outbound Rules**:
        - Allow all outgoing traffic to the internet.
- **Outputs**:
    - `appserver_elb_sg_id` (used by EC2 Appserver).
    - `appserverTG` (used by ASG Appserver).

---

## Step 8: CloudFront Module
- **Domain Name**: `cloudfront_domain_name`.
- **Origin Protocol Type**: HTTP.
- **Viewer Protocol**: `redirect-to-https`.
- **Whitelisted Countries**: `["US", "CA", "KE"]`.
- **Outputs**:
    - `cloudfront_domain_name` (displayed on terminal).

---

## Step 9: CloudTrails Module
- **Create an S3 Bucket** to store CloudFront logs.
- **Create CloudTrail** to log CloudFront events.

---

## Step 10: Root Module (`main.tf`)
- **Initialize all modules** with their sources and dependent arguments.

---

## Step 11: Root Module (`outputs.tf`)
- **Outputs**:
    - `cloudfront_domain_name`.
    - `frontend_lb_dns_name`.
