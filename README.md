## 📐 Architecture Overview

This project provisions a **3-tier web application infrastructure on AWS** using Terraform. It is designed to be highly available, redundant, and secure — with resources distributed across multiple Availability Zones.

The infrastructure is built from **6 custom-written, reusable Terraform modules** covering networking, compute, load balancing, and database layers. A dedicated remote backend environment manages Terraform state securely using an S3 bucket with KMS encryption.

Key highlights:
- **High availability** — resources span 3 AZs (`eu-central-1a/b/c`)
- **Security in depth** — layered Security Groups, private subnets, encrypted state backend
- **Scalable compute** — Auto Scaling Group with ELB health checks
- **Managed database** — Aurora PostgreSQL cluster with Multi-AZ support
- **Reusable modules** — each module has a clean interface and can be used independently

## 📁 Project Structure

```
web-app.hcl/
├── environments/
│   ├── dev/                        # Dev environment entrypoint
│   │   ├── main.tf                 # Module orchestration
│   │   ├── variables.tf            # Environment-specific variables
│   │   ├── configuration.tf        # Provider & backend config
│   │   ├── Data.tf                 # AMI data source
│   │   └── user_data/
│   │       ├── Server1.sc          # EC2 bootstrap script (Apache + app)
│   │       └── Server2.sc
│   └── remote-backend/             # S3 backend provisioning
│       ├── Resources.tf
│       └── configuration.tf
│
└── modules/
    ├── vpc/                        # VPC, Subnets, IGW, NAT, Route Tables
    ├── sg/                         # Reusable Security Groups (CIDR & SG-source rules)
    ├── ec2/                        # EC2 instances (individual)
    ├── autoscaling_group/          # ASG + Launch Template
    ├── web-loadbalancer/           # ALB, Listeners, Target Groups
    └── RDS-Postgresql-Multi-AZ/    # Aurora PostgreSQL Cluster
```

## 🚀 Quick Start

### 1. Provision the Remote Backend (first time only)

```bash
cd environments/remote-backend
terraform init
terraform apply
```

### 2. Deploy the Dev Environment

```bash
cd environments/dev

# Create a secrets file for the DB password
mkdir -p Secrets
echo "YourSecurePassword123!" > Secrets/mainDB.Password.txt
# .Note! : this directory is ignored by git

# Initialize and deploy
terraform init
terraform workspace new dev   # or: terraform workspace select dev
terraform plan
terraform apply
```

### 3. Check the Load Balancer URL

After a successful apply, the ALB DNS name is saved to:
```
environments/dev/Outputs/lb_url.txt
```

---

## 🔧 Modules Reference

### `vpc` — Networking Foundation

| Variable | Description | Default |
|----------|-------------|---------|
| `VPC_CIDR` | CIDR block for the VPC | `10.0.0.0/16` |
| `Public_Subnets` | List of `{az, cidr}` for public subnets | 2 subnets across 2 AZs |
| `Private_Subnets` | List of `{az, cidr, use_nat_gwy}` for private subnets | 3 subnets across 3 AZs |

**Creates**: VPC, Public/Private Subnets, Internet Gateway, NAT Gateway (EIP), Route Tables & Associations.

---

### `sg` — Flexible Security Groups

Supports **dual-mode rules** — either CIDR-based or Security-Group-source-based:

```hcl
# CIDR-based (for public-facing LB)
Inbound = [{ cidr_block = "0.0.0.0/0", port = "80", ip_protocol = "tcp" }]

# SG-source-based (for app tier — only traffic from LB SG)
Inbound = [{ sg_source = module.Load_balancer_SG.SG_ID, port = "80", ip_protocol = "tcp" }]
```

---

### `autoscaling_group` — Auto Scaling

| Variable | Default |
|----------|---------|
| `MinSize` | `3` |
| `DesiredCapacity` | `3` |
| `MaxSize` | `5` |
| `health_check_type` | `"ELB"` |

Uses **Launch Templates** (not legacy Launch Configurations) with `user_data` for automatic application bootstrapping.

---

### `web-loadbalancer` — Application Load Balancer

- Creates ALB, Listeners, Target Groups, and Target Group Attachments dynamically
- Uses `for` + `flatten` expressions to handle multiple forwarding rules with multiple instance targets
- `lifecycle { create_before_destroy = true }` prevents downtime during updates

---

### `RDS-Postgresql-Multi-AZ` — Aurora Cluster

- Engine: `aurora-postgresql`
- Multi-AZ with automatic failover
- Configurable backup retention window

---

## 🌍 Multi-Environment Design

The project uses **Terraform Workspaces** to manage environments with the same codebase:

```hcl
# variables.tf
variable "instance_types" {
  default = {
    "default" = "t3.micro"   # dev
    "prod"    = "t3.medium"  # production
  }
}

# Usage in main.tf
instance_type = var.instance_types[terraform.workspace]
```

---

## 🔒 Security Considerations

- ✅ Database password stored in a local `Secrets/` file — excluded from version control via `.gitignore`
- ✅ All EC2 instances in **private subnets** with no public IP addresses
- ✅ **Layered Security Groups** — each tier only accepts traffic from the tier directly above it
  - Load Balancer SG: accepts port `80` from the internet only
  - Web/App SG: accepts port `80` from the **LB SG only**
  - DB SG: accepts port `5432` (Aurora PostgreSQL) from the **Web SG only**
- ✅ Terraform remote state stored in **S3 with KMS encryption** (`aws:kms`)
- ✅ S3 backend bucket encrypted with a dedicated **AWS KMS Customer Managed Key**

---

## 📊 AWS Resources Provisioned

| Resource | Count | Notes |
|----------|-------|-------|
| VPC | 1 | `10.0.0.0/16` — `eu-central-1` |
| Public Subnets | 2 | `eu-central-1a`, `eu-central-1b` |
| Private Subnets | 3 | `eu-central-1a`, `eu-central-1b`, `eu-central-1c` |
| Internet Gateway | 1 | Attached to VPC |
| NAT Gateway | 1 | With Elastic IP — outbound for private subnets |
| Application Load Balancer | 1 | Public-facing, HTTP port 80 |
| Auto Scaling Group | 1 | min: 3, desired: 3, max: 5 — ELB health check |
| EC2 Launch Template | 1 | Ubuntu 22.04 LTS — Apache + app via user data |
| Security Groups | 3 | LB SG, Web SG, DB SG |
| Aurora PostgreSQL Cluster | 1 | Multi-AZ — port 5432 |
| DB Subnet Group | 1 | Spans all 3 private subnets |
| S3 Bucket | 1 | Terraform remote state backend |
| KMS Key | 1 | Encrypts S3 remote state bucket |

---

<div align="center">

**Built with ❤️ and Terraform by [ABDELBARI](https://github.com/AbdelbariLa)**

*Capstone project — AWS & Terraform Infrastructure Engineering*

</div>
