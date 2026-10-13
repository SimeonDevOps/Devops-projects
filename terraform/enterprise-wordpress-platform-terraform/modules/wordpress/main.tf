data "aws_ssm_parameter" "ubuntu" {
  name = var.ami_ssm_parameter
}

resource "aws_iam_role" "ssm" {
  name = "${var.name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "${var.name}-ssm-profile"
  role = aws_iam_role.ssm.name

  tags = var.tags
}

resource "aws_eip" "wordpress" {
  count = var.allocate_eip ? 1 : 0

  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-eip"
    }
  )
}

locals {
  effective_site_url = (
    var.site_url != null
    ? var.site_url
    : var.allocate_eip
    ? "http://${aws_eip.wordpress[0].public_ip}"
    : ""
  )
}

resource "aws_instance" "wordpress" {
  ami                         = data.aws_ssm_parameter.ubuntu.value
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ssm.name

  user_data_replace_on_change = true

  user_data = templatefile(
    "${path.module}/user_data.sh.tftpl",
    {
      wordpress_version            = var.wordpress_version
      wordpress_title_b64          = base64encode(var.wordpress_title)
      wordpress_admin_user         = var.wordpress_admin_user
      wordpress_admin_email_b64    = base64encode(var.wordpress_admin_email)
      wordpress_admin_password_b64 = base64encode(var.wordpress_admin_password)
      wordpress_db_name            = var.wordpress_db_name
      wordpress_db_user            = var.wordpress_db_user
      wordpress_db_password_b64    = base64encode(var.wordpress_db_password)
      site_url_b64                 = base64encode(local.effective_site_url)
    }
  )

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
      Role = "wordpress"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.ssm_core
  ]
}

resource "aws_eip_association" "wordpress" {
  count = var.allocate_eip ? 1 : 0

  allocation_id = aws_eip.wordpress[0].id
  instance_id   = aws_instance.wordpress.id
}