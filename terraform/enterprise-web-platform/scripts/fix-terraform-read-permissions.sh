

#!/usr/bin/env bash
set -euo pipefail

# Generates an IAM policy for the three AWS read permissions
# currently denied during Terraform plan.

POLICY_FILE="scripts/terraform-read-permissions.json"

cat > "$POLICY_FILE" <<'POLICY'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadDbBootstrapIamRole",
      "Effect": "Allow",
      "Action": [
        "iam:GetRole"
      ],
      "Resource": "arn:aws:iam::456823160821:role/enterprise-web-platform-dev-db-bootstrap-role"
    },
    {
      "Sid": "DescribeEfsFileSystems",
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:DescribeFileSystems"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DescribeRdsDbSubnetGroups",
      "Effect": "Allow",
      "Action": [
        "rds:DescribeDBSubnetGroups"
      ],
      "Resource": "arn:aws:rds:us-east-1:456823160821:subgrp:enterprise-web-platform-dev-mysql-subnets"
    }
  ]
}
POLICY

echo "Created IAM policy file: $POLICY_FILE"
echo
echo "Review the policy before an AWS administrator applies it:"
cat "$POLICY_FILE"
