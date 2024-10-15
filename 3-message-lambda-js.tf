data "archive_file" "js_message_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/js/src"
  output_path = "${path.module}/code.zip"
}

resource "aws_iam_role" "js_lambda_iam_role" {
  name = "lambda-iam-role"

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

resource "aws_lambda_function" "js_message_lambda" {
  function_name    = "hello-js-lambda"
  handler          = "HandleMessage.handler"
  runtime          = "nodejs20.x"
  filename         = data.archive_file.js_message_lambda_zip.output_path
  source_code_hash = data.archive_file.js_message_lambda_zip.output_base64sha256
  role             = aws_iam_role.js_lambda_iam_role.arn
  environment {
    variables = {
      "MESSAGE" = "Terraform sends its regards"
    }
  }
}