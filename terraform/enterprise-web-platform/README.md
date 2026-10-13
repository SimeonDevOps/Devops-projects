# Enterprise Web Platform — Terraform & Cloud-Init

**Client case study:** Global Technology Enterprise (GTE) — simulated enterprise client  
**Project type:** Cloud infrastructure automation and enterprise platform engineering  
**Cloud provider:** Amazon Web Services (AWS)  
**Infrastructure as Code:** Terraform  
**Operating system configuration:** cloud-init  
**Portfolio status:** Update implementation and validation status as the project progresses.

---

## 1. Executive Summary

### The business challenge

A business that depends on a web application needs more than a server that can display a webpage. It needs an infrastructure foundation that can be deployed consistently, configured automatically, secured appropriately, monitored and recovered when something goes wrong.

For this simulated engagement, Global Technology Enterprise (GTE) needs a repeatable method for provisioning a web platform in AWS. The objective is to reduce manual server setup, make infrastructure changes reviewable, and establish a foundation that can evolve into a more resilient enterprise application environment.

Manual provisioning creates operational risk. Engineers may configure servers differently, forget required packages, open unnecessary network ports or struggle to reproduce an environment after a failure. It also makes handover to another engineer harder.

### The proposed solution

I designed a Terraform-based infrastructure-as-code approach that separates infrastructure provisioning from operating-system configuration.

Terraform declares the desired cloud resources. AWS provisions the underlying infrastructure. Cloud-init configures the EC2 instance during its initial boot, installing NGINX and creating a web page and health-check endpoint.

The project then establishes a path toward a modular enterprise architecture, where reusable Terraform modules can support separate development, staging and production environments.

### Business value

- **Repeatability:** deploy the same configuration consistently.
- **Reduced manual effort:** install and configure software automatically.
- **Change control:** review infrastructure plans before making changes.
- **Maintainability:** separate variables, outputs, templates and resource definitions.
- **Operational visibility:** expose useful deployment outputs and provide a health endpoint.
- **Scalability of design:** evolve from a single-instance demonstration to a modular platform.
- **Knowledge transfer:** document deployment, troubleshooting and recovery procedures.

This is a portfolio case study using a fictional client. It does not represent a production deployment for a real enterprise.

---

## 2. Architecture Overview

### Baseline deployment

```text
Engineer
   |
   v
GitHub Repository
   |
   v
Terraform CLI
   |
   +------> S3 Remote State
   |
   v
AWS VPC
   |
   v
Public Subnet
   |
   v
EC2 Instance
   |
   v
cloud-init
   |
   +------> Install NGINX
   +------> Create Homepage
   +------> Create /healthz
   |
   v
Public HTTP Endpoint
```

### Intended enterprise evolution

```text
Users
  |
  v
Route 53 DNS
  |
  v
ACM TLS Certificate
  |
  v
Application Load Balancer
  |
  v
Private WordPress Auto Scaling Group
  |
  +------> Amazon EFS for shared uploads
  |
  +------> Private Amazon RDS database
  |
  +------> AWS Secrets Manager
  |
  +------> Amazon CloudWatch
  |
  +------> AWS Backup

GitHub Actions
  |
  v
GitHub OIDC
  |
  v
Environment-specific AWS deployment role
  |
  v
Terraform plan and controlled apply
```

The enterprise architecture is a target design until its modules, deployment workflow, security controls and recovery procedures have actually been implemented and tested.

---

## 3. Scope

### Baseline implementation

The initial implementation focuses on:

- Terraform AWS provider configuration.
- EC2 provisioning.
- VPC, subnet, route and security-group configuration.
- IAM instance profile for Systems Manager where configured.
- Cloud-init-based NGINX installation.
- Public HTTP endpoint.
- Health-check endpoint.
- Terraform variables and outputs.
- Remote S3 state.
- Deployment verification and troubleshooting documentation.

### Enterprise extension

The planned extension includes:

- Reusable Terraform modules.
- Multiple Availability Zones.
- Public Application Load Balancer.
- HTTPS through AWS Certificate Manager.
- Route 53 DNS.
- Private application and database subnets.
- WordPress Auto Scaling.
- Amazon RDS for MySQL.
- Amazon EFS for shared WordPress uploads.
- AWS Secrets Manager.
- Amazon CloudWatch alarms and notifications.
- AWS Backup and a documented disaster-recovery strategy.
- Separate dev, stage and production configurations.
- GitHub Actions CI/CD using GitHub OIDC.
- Separate AWS accounts for stronger environment isolation.

Each enterprise capability must be verified independently before being described as complete.

---

## 4. Repository Structure

```text
enterprise-web-platform/
├── README.md
├── .gitignore
├── bootstrap/
│   └── state/
├── environments/
│   ├── dev/
│   ├── stage/
│   └── prod/
├── examples/
│   └── cloud-init-nginx/
├── modules/
│   ├── network/
│   ├── security/
│   ├── database/
│   ├── storage/
│   ├── load_balancer/
│   ├── wordpress/
│   ├── dns_tls/
│   ├── observability/
│   └── backup/
├── docs/
│   ├── architecture.md
│   └── screenshots/
└── .github/
    └── workflows/
```

### Design principles

**Separation of concerns:** each module has one primary responsibility.

**Don't Repeat Yourself (DRY):** common resource definitions live in reusable modules rather than being copied into each environment.

**Configuration through inputs:** region, subnet CIDRs, instance types, environment names and other settings are supplied through variables.

**Explicit outputs:** modules expose only the values that other modules or operators need.

**Environment isolation:** dev, stage and prod use distinct configuration and state keys; separate AWS accounts are intended for the mature environment design.

---

## 5. Terraform File Responsibilities

| File | Responsibility |
|---|---|
| `main.tf` | Declares resources and module calls |
| `provider.tf` | Configures the AWS provider |
| `versions.tf` | Pins Terraform and provider version constraints |
| `variables.tf` | Defines inputs and their types |
| `locals.tf` | Calculates internal names, tags and derived values |
| `outputs.tf` | Exposes useful values after deployment |
| `terraform.tfvars.example` | Documents example input values |
| `backend.tf` | Declares the remote state backend |
| `backend.hcl.example` | Shows non-secret backend settings |
| `cloud-init.yaml.tftpl` | Defines operating-system startup configuration |

Terraform loads `.tf` files in the same directory as one configuration. The filename helps people understand the code; it does not make the resources behave differently.

---

## 6. How the Deployment Works

### Step 1 — Define the desired infrastructure

Terraform configuration describes resources, their settings, dependencies and relationships.

### Step 2 — Initialize the working directory

`terraform init` installs the required provider and configures the backend.

### Step 3 — Validate the configuration

`terraform fmt` formats the code. `terraform validate` checks configuration syntax and consistency.

### Step 4 — Review the execution plan

`terraform plan` compares the desired configuration with the known infrastructure state and proposes changes.

### Step 5 — Apply the reviewed plan

`terraform apply` asks AWS to create or modify the required resources.

### Step 6 — Configure the operating system

EC2 starts, cloud-init processes its configuration, installs NGINX and writes the application files.

### Step 7 — Verify the service

The public homepage and `/healthz` endpoint are tested. Cloud-init and NGINX logs are inspected if the service fails.

### Step 8 — Capture evidence

Screenshots and test results are added to `docs/screenshots/`.

---

## 7. Cloud-Init

Cloud-init automates first-boot configuration of the Linux operating system.

The template uses:

- `package_update` to refresh package metadata.
- `packages` to install software.
- `write_files` to create the homepage and health file.
- `runcmd` to enable and start NGINX.

Terraform renders the template using `templatefile()` and passes the rendered configuration to EC2 through `user_data`.

This separates operating-system configuration from the Terraform resource definition, making the startup process easier to inspect and maintain.

---

## 8. Reusable Terraform Concepts

The project is intended to demonstrate the following language features where they solve real configuration problems:

- **Input variables:** allow configuration to change without rewriting resource definitions.
- **Variable types:** enforce the expected form of inputs, including strings, numbers, booleans, lists and maps.
- **Variable validation:** reject invalid or inconsistent input values early.
- **Locals:** define calculated values used inside the configuration.
- **Outputs:** expose IDs, URLs and other useful resource attributes.
- **`merge()`:** combine common tags with environment-specific tags.
- **`concat()`:** combine lists such as common and environment-specific rule collections.
- **`coalesce()`:** select the first usable value from a sequence of alternatives.
- **`try()`:** handle an expression that may not be available, such as an optional resource.
- **Conditional expressions:** select configuration based on an environment or feature flag.
- **`count`:** create a number of instances when resources are intentionally indexed.
- **`for_each`:** create resources from a set or map with stable keys.
- **`for` expressions:** transform input collections into maps or lists.
- **`range()`:** generate integer sequences for indexed configuration.
- **`slice()`:** select a range from a list.
- **`upper()` and `lower()`:** normalize strings when a naming or validation rule requires it.
- **`can()`:** check whether an expression can be evaluated.
- **`dynamic` blocks:** generate repeated nested configuration blocks.
- **`file()` and `templatefile()`:** load files and render templates.
- **`jsonencode()` and `jsondecode()`:** serialize and parse JSON where appropriate.

These constructs should be included because they make the configuration clearer or more reusable, not simply to demonstrate every function in every resource.

---

## 9. Security Design

The security approach should evolve alongside the architecture.

### Network security

- Expose only the required public entry point.
- Keep application and database tiers in private subnets.
- Allow application traffic from the load balancer rather than from arbitrary sources.
- Restrict database access to the application security group.
- Restrict EFS access to the application tier.

### Identity and secrets

- Use IAM roles rather than embedding AWS credentials in scripts.
- Use Systems Manager for instance administration instead of opening SSH unnecessarily.
- Use Secrets Manager for database credentials.
- Restrict secret retrieval to the identities that need it.
- Protect Terraform state because it may contain sensitive values.

### Transport and data protection

- Use HTTPS for the production endpoint.
- Encrypt database storage, EFS and the remote state bucket.
- Enable appropriate S3 versioning and access controls.
- Restrict access to production deployment roles.

The baseline HTTP example is for learning and verification. It should not be represented as a fully production-secure website.

---

## 10. Remote State

Terraform state records the relationship between configuration and the resources Terraform manages.

For collaborative use, the project uses an S3 backend with:

- A unique state key per configuration.
- Encryption.
- S3 versioning on the state bucket.
- Native S3 lockfile support.
- Restricted IAM access.

Example state key:

```text
enterprise-web-platform/examples/cloud-init-nginx/terraform.tfstate
```

Environment configurations use separate keys for dev, stage and prod.

State is operationally important and may contain sensitive information. It must not be committed to Git or treated as an ordinary application file.

---

## 11. CI/CD Strategy

The intended GitHub Actions pipeline is:

```text
Pull Request
    |
    v
Terraform Format Check
    |
    v
Terraform Validation
    |
    v
Security and Policy Checks
    |
    v
Terraform Plan
    |
    v
Human Review
    |
    v
Approved Deployment
    |
    v
Smoke Test
```

GitHub OIDC is intended to provide short-lived AWS credentials without storing long-lived AWS access keys in GitHub repository secrets.

Production deployment should require explicit approval and use a role scoped to the production account and environment.

---

## 12. Monitoring and Disaster Recovery

The enterprise design uses CloudWatch for application and infrastructure alarms, and AWS Backup for managed recovery points.

A disaster-recovery strategy must define:

- Recovery Point Objective (RPO): acceptable data loss measured in time.
- Recovery Time Objective (RTO): target time to restore the service.
- Backup retention.
- Recovery-region requirements.
- DNS cutover procedure.
- Database and shared-file restore procedure.
- Regular restore testing.

Backup creation alone does not prove recoverability. A restore should be performed and documented before claiming that the recovery process has been tested.

---

## 13. Deployment Instructions

From the example directory:

```bash
terraform init -backend-config=backend.hcl
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Retrieve the website URL:

```bash
terraform output -raw site_url
```

Check the health endpoint:

```bash
curl -i "$(terraform output -raw healthcheck_url)"
```

These commands apply to the baseline NGINX example. The enterprise environment has its own backend configuration and must be initialized and planned independently.

---

## 14. Troubleshooting

Check cloud-init:

```bash
sudo cloud-init status --long
sudo tail -n 100 /var/log/cloud-init-output.log
```

Check NGINX:

```bash
sudo systemctl status nginx --no-pager
sudo journalctl -u nginx --no-pager -n 100
```

Check the endpoint from WSL:

```bash
curl -i "$(terraform output -raw healthcheck_url)"
```

For a timeout, check the EC2 instance state, public address, subnet route and security group. For a cloud-init failure, inspect the boot log before modifying or replacing the instance.

---

## 15. Evidence and Validation

The screenshots directory should contain genuine evidence from the AWS account:

- Homepage in a browser.
- Successful health-check response.
- Terraform apply output.
- EC2 instance details.
- Security-group rules.
- Remote state bucket configuration.
- Cloud-init completion.
- Enterprise ALB, HTTPS, RDS, Auto Scaling, monitoring and backup evidence as those features are implemented.

A screenshot should support a specific claim. Features that have not been deployed and tested must remain labelled as planned or in progress.

---

## 16. Cost and Operational Considerations

AWS charges vary by region, resource configuration, traffic and usage. NAT gateways, load balancers, EC2 instances, RDS, EFS, backups, logs and data transfer can all contribute to costs.

The baseline is designed to demonstrate the workflow with a small instance. The enterprise design is more expensive and should be deployed in stages.

Before applying an environment, review the plan and estimate its cost. Destroy temporary resources when they are no longer required, while preserving any state or recovery resources that still need to exist.

---

## 17. Project Outcomes

The baseline demonstrates an infrastructure-as-code workflow from configuration to a working HTTP endpoint. The intended enterprise evolution extends that foundation toward a modular, secure, monitored and recoverable web platform.

The value of this project is not the number of AWS services used. It is the ability to explain the business problem, justify the architecture, automate deployment, manage change safely, troubleshoot failures and demonstrate evidence of the result.

## 18. Implementation Status

Maintain this section as work progresses:

| Capability | Status |
|---|---|
| EC2 + cloud-init NGINX | Update after successful verification |
| Terraform variables and outputs | Update after validation |
| S3 remote state | Update after successful initialization |
| Reusable network module | Planned until implemented |
| RDS and Secrets Manager | Planned until deployed and verified |
| ALB and HTTPS | Planned until deployed and verified |
| Auto Scaling and EFS | Planned until deployed and verified |
| CloudWatch alarms | Planned until tested |
| AWS Backup and restore test | Planned until verified |
| GitHub OIDC CI/CD | Planned until pipeline succeeds |
| Separate AWS accounts | Planned until configured |

---

## 19. Final Consultant Perspective

This project demonstrates how I approach cloud engineering as a business problem rather than a collection of isolated services.

I begin with a working baseline, automate repeatable tasks, separate concerns into reusable components, protect infrastructure state, review changes before deployment, and validate the result using observable evidence.

From that foundation, I can evolve the design according to the client's availability, security, recovery and cost requirements—without introducing unnecessary complexity before the business needs it.