terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
        
#                   <<===================>>
#                 <<                       >>
#               <<        [=========]        >>
#             <<          [ modules ]          >>
#               <<        [=========]        >>
#                 <<                       >>
#                   <<===================>>
#

module "vpc" {
  source = "./modules/vpc"
  vpc-cidr = var.vpc_cidr
  subnet-cidr = var.subnet_cidr
  my-ip = var.my_ip
}

module "ec2" {
  source            = "./modules/ec2"
  subnet_id         = module.vpc.subnet_id
  security_group_id = module.vpc.security_group_id
  ec2-type = var.ec2_type
  machine-name = var.machine_name
}

#                       __________
#                      |..........|
#                      | Database |
#                      |__________|

resource "aws_dynamodb_table" "dynamodb-emails-table" {
  name           = "EmailsTable"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "email"
  range_key      = "name"


  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "name"   # Define the range_key
    type = "S"
  }

}


#                       _________
#                      |.........|
#                      |   IAM   |
#                      |_________|

resource "aws_iam_role" "lambda_role" {
  name = "lambda_to_dynamodb"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "Lambda_to_db"
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_dynamodb_put_item"
  path        = "/"
  description = "Policy that allows lambda to put data into DynamoDB"


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem*",
          "dynamodb:DeleteItem",
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.dynamodb-emails-table.arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

output "lambda_role_name" {
  value = aws_iam_role.lambda_role.name
}

output "line1" {
  value = "policy details:"
}

output "lambda_policy_name" {
  value = aws_iam_role.lambda_role.name
}

output "lambda_policy_disc" {
  value = aws_iam_role.lambda_role.description
}

output "line2" {
  value = "policy permesions:"
}

output "lambda_policy_effect" {
  value = jsondecode(aws_iam_role.lambda_role.assume_role_policy).Statement[0].Effect
}

output "lambda_policy_actions" {
  value = jsondecode(aws_iam_role.lambda_role.assume_role_policy).Statement[0].Action
}

#                  ____________________
#                 |....................|
#                 |   Lambda Function  |
#                 |____________________|



data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "email_function" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "lambda_email_function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  timeout = 20
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  runtime = "python3.13"
  
  depends_on = [ aws_iam_role_policy_attachment.lambda_dynamodb_attach, ]

  environment {
    variables = {
      foo = "bar"
    }
  }

}

#                       _______
#                      |.......|
#                      |  API  |
#                      |_______|

resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "lambda_http_api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = [ "*" ]
    allow_methods = ["POST", "GET", "OPTIONS"]
    allow_headers = [ "Content-Type" ]
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.lambda_api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.email_function.invoke_arn
}

resource "aws_apigatewayv2_route" "post_route" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "POST /submit"

  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.lambda_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw_lambda" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda_api.execution_arn}/$default/POST/submit"
}

# Output API Gateway Invoke URL
output "api_gateway_url" {
  value = aws_apigatewayv2_api.lambda_api.api_endpoint
}


#adding the API invoke url to the .env file automaticly
resource "null_resource" "write_env_file" {
  provisioner "local-exec" {
    command = <<EOT
      echo "API_GATEWAY_URL=${aws_apigatewayv2_api.lambda_api.api_endpoint}" > .env
    EOT
  }

  depends_on = [aws_apigatewayv2_api.lambda_api]
}


