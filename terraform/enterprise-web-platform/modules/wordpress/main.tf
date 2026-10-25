data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ec2" {
  name = "${var.name_prefix}-wordpress-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "application_access" {
  name = "${var.name_prefix}-wordpress-runtime-access"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ReadApplicationDatabaseSecret"
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = var.application_secret_arn_pattern
      },
      {
        Sid    = "MountAndWriteWordPressUploads"
        Effect = "Allow"
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite"
        ]
        Resource = [
          var.efs_file_system_arn,
          var.efs_access_point_arn
        ]
        Condition = {
          StringEquals = {
            "elasticfilesystem:AccessPointArn" = var.efs_access_point_arn
          }
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name_prefix}-wordpress-profile"
  role = aws_iam_role.ec2.name

  tags = var.tags
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.name_prefix}-wordpress-"
  image_id      = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  vpc_security_group_ids = [var.security_group_id]

  user_data = base64encode(templatefile(
    "${path.module}/user_data.sh.tftpl",
    {
      aws_region              = var.aws_region
      application_secret_name = var.application_secret_name
      db_name                 = var.db_name
      efs_file_system_id      = var.efs_file_system_id
      efs_access_point_id     = var.efs_access_point_id
      site_url                = var.site_url
      bootstrap_log_group_name = var.bootstrap_log_group_name
      apache_log_group_name    = var.apache_log_group_name
    }
  ))

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, {
      Name = "${var.name_prefix}-wordpress"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags          = var.tags
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy.application_access,
    aws_iam_role_policy_attachment.ssm
  ]
}

resource "aws_autoscaling_group" "this" {
  name                = "${var.name_prefix}-wordpress-asg"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [var.target_group_arn]

  health_check_type         = "ELB"
  health_check_grace_period = 900
  default_cooldown          = 300

  launch_template {
  id      = aws_launch_template.this.id
  version = aws_launch_template.this.latest_version
}

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 900
    }
  }

  dynamic "tag" {
    for_each = merge(var.tags, {
      Name = "${var.name_prefix}-wordpress"
    })

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }

  depends_on = [
    aws_iam_role_policy.application_access,
    aws_iam_role_policy_attachment.ssm
  ]
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role = aws_iam_role.ec2.name

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
