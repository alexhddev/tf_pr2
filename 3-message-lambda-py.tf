data "archive_file" "py_message_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/py/code"
  output_path = "${path.module}/.terraform/py_code.zip"
}

resource "aws_iam_role" "py_lambda_iam_role" {
  name = "py_lambda_iam_role"

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

resource "aws_lambda_function" "py_message_lambda" {
  function_name    = "hello-py-lambda"
  handler          = "lambda.main"
  runtime          = "python3.11"
  filename         = data.archive_file.py_message_lambda_zip.output_path
  source_code_hash = data.archive_file.py_message_lambda_zip.output_base64sha256
  role             = aws_iam_role.py_lambda_iam_role.arn
  environment {
    variables = {
      "MESSAGE" = "Terraform sends its regards"
    }
  }
}