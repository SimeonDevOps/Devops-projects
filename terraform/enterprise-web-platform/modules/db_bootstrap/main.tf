data "archive_file" "lambda_package" {
  type        = "zip"
  source_dir  = "${path.module}/build/package"
  output_path = "${path.module}/build/db-bootstrap.zip"
}


data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_iam_role" "lambda" {
  name = "${var.name_prefix}-db-bootstrap-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "secrets" {
  name = "${var.name_prefix}-db-bootstrap-secrets"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ReadRdsMasterSecret"
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = var.master_secret_arn
      },
      {
        Sid    = "ManageApplicationSecret"
        Effect = "Allow"
        Action = [
          "secretsmanager:CreateSecret",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:TagResource"
        ]
        Resource = "arn:aws:secretsmanager:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:secret:${var.application_secret_name}-*"
      }
    ]
  })
}

resource "aws_lambda_function" "this" {
  function_name = "${var.name_prefix}-db-bootstrap"
  description   = "Creates the least-privilege WordPress database user."
  role          = aws_iam_role.lambda.arn
  runtime       = "python3.12"
  handler       = "handler.handler"

  filename         = data.archive_file.lambda_package.output_path
  source_code_hash = data.archive_file.lambda_package.output_base64sha256
  timeout          = 120
  memory_size      = 256

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [var.security_group_id]
  }

  environment {
    variables = {
      MASTER_SECRET_ARN = var.master_secret_arn
      APP_SECRET_NAME   = var.application_secret_name
      DB_ENDPOINT       = var.db_endpoint
      DB_PORT           = tostring(var.db_port)
      DB_NAME           = var.db_name
    }
  }

  depends_on = [
    aws_iam_role_policy.secrets,
    aws_iam_role_policy_attachment.lambda_logs,
    aws_iam_role_policy_attachment.lambda_vpc
  ]

  tags = var.tags
}

resource "aws_lambda_invocation" "provision_database_user" {
  function_name = aws_lambda_function.this.function_name

  input = jsonencode({
    operation = "ensure-wordpress-database-user"
  })

  triggers = {
    function_hash = data.archive_file.lambda_package.output_base64sha256
    endpoint      = var.db_endpoint
    database      = var.db_name
    secret_name   = var.application_secret_name
  }

  depends_on = [aws_lambda_function.this]
}