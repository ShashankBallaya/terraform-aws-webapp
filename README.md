# Terraform AWS 3-Tier Web Application

> Production-grade 3-tier HA architecture on AWS provisioned entirely
> with Terraform. One command deploys everything. One command destroys it.

## Key Features
- Fully modular Terraform codebase (reusable components)
- High availability across 2 Availability Zones
- Secure architecture (no public EC2, DB isolated)
- Auto Scaling EC2 with ALB integration
- Remote state management with locking (S3 + DynamoDB)
- One-command deployment and teardown 

## Live Demo 
Deployed and tested - `terraform apply` provisions all resources in ~8 minutes.
ALB DNS confirmed serving traffic from EC2 instances in private subnets.

## Architecture
![Architecture](architecture/Project-2_Architecture.png)

```
Internet
 ↓
ALB (public subnets — 10.0.1.0/24, 10.0.3.0/24)
 ↓ port 80
EC2 ASG (private subnets — 10.0.10.0/24, 10.0.11.0/24)
 ↓ port 3306 ↓
RDS MySQL NAT Gateway → Internet (outbound only)
(DB subnets — 10.0.12.0/24, 10.0.13.0/24)
```

## Tech Stack
| Tool | Purpose |
|---|---|
| Terraform | Infrastructure as Code - all resources |
| AWS VPC | Custom network - 6 subnets across 2 AZs |
| AWS ALB | Internet-facing load balancer |
| AWS EC2 Auto Scaling | 2 instances, scales 1-4, private subnets |
| AWS NAT Gateway | Outbound internet for private EC2 instances |
| AWS RDS MySQL | Managed database - private EC2 instances |
| S3 + DynamoDB | Terraform remote state + locking |

## Security Design
| Layer | Security Group | Rule |
|---|---|---|
| ALB | alg-sg | Port 80/443 from 0.0.0.0/0 |
| EC2 | ec2-sg | Port 80 from alb-sg only |
| RDS | rds-sg | Port 3306 from ec2-sg only |

The database is never directly reachable from the internet.
EC2 instances have no public IPs - only reachable via ALB.

## How to Deploy
```bash
# 1. Clone the repo
git clone https://github.com/ShashankBallaya/terraform-aws-webapp
cd terraform-aws-webapp

# 2. Create terraform.tfvars (never commit this file)
cp terraform.tfvars.example terraform.tfvars
# Edit with your IP and DB password

# 3. Deploy
terraform init
terraform plan 
terraform apply

# 4. Visit the output URL
# alb_dns_name = webapp-alb-XXXXX.ap-south-1.elb.amazonaws.com

# 5. Destroy when done 
terraform destroy
```

## Terraform Module Structure
```

```
## What I Learned
- Designed and deployed a highly available 3-tier architecture using Terraform with modular infrastructure (VPC, LAB, ASG, RDS).
- Gained hands-on experience with networking concepts like public vs private subnets, route tables, NAT Gateway, and secure traffic flow between tiers.
- Implemented Infrastructure as Code best practices, including remote state management (S3 + DynamoDB) and reusable module structure.

## Challenges 
- Misconfigured route tables initially caused private EC2 instances to lose outbound internet access - fixed by correctly routing through the NAT Gateway.
- Faced issues with Auto Scaling instances not registering with the target group due to an incorrect health check path and user data debugging.
- Accidentally broke infrastructure during Terraform changes - learned to use `terraform taint`, state awareness, and incremental applies to recover safely.

## Cost
`terraform destroy` run after testing - zero ongoing cost.
NAT Gateway ($0.045/hr) is the most expensive resource - always destroy after use.

## Next Steps 
- Add HTTPS with ACM certificate on the ALB
- Add a bastion host for secure SSH access to private EC2
- Add CloudWatch dashboard and CPU alarms
