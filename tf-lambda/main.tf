# Configure AWS as the cloud provider
provider "aws" {
  version = "~> 3.0"
  region  = var.aws_region
}

# Create archive file
# https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/archive_file
data "archive_file" "greet_lambda" {
  type        = "zip"
  source_file = "greet_lambda.py"
  output_path = "greet_lambda.zip"
}

# Create IAM role for lambda
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Create logging policy
# https://knowledge.udacity.com/questions/286910
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_resource_policy
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name = aws_lambda_function.greet_lambda.function_name
  retention_in_days = 14
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

# Create lambda function
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
# https://registry.terraform.io/modules/terraform-module/lambda/aws/2.12.4
resource "aws_lambda_function" "greet_lambda" {
  filename = "greet_lambda.zip"
  function_name = "greet_lambda"
  role = aws_iam_role.iam_for_lambda.arn
  handler = "greet_lambda.lambda_handler"
  runtime = "python3.8"
  memory_size = "128"
  timeout = "20"

  environment {
    variables = {
      greeting = "Hello, World!"
    }
  }
}