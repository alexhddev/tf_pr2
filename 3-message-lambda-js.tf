data "archive_file" "js_message_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/js/dist"
  output_path = "${path.module}/.terraform/js_code.zip"
  depends_on  = [null_resource.npm_build]
}

resource "aws_iam_role" "js_lambda_iam_role" {
  name = "js_lambda_iam_role"

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

resource "aws_iam_role_policy_attachment" "js_messages_lambda_policy_attachment" {
  role       = aws_iam_role.js_lambda_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "js_messages_lambda_role_policy_attachment" {
  role       = aws_iam_role.js_lambda_iam_role.name
  policy_arn = aws_iam_policy.messages_bucket_access_lambda_policy.arn
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
      MESSAGES_BUCKET = aws_s3_bucket.messages_bucket.id
    }
  }

}

resource "null_resource" "npm_build" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "npm run build"
    working_dir = "${path.module}/js"
  }

  depends_on = [null_resource.npm_install]
  
}

resource "null_resource" "npm_install" {
  triggers = {
    shell_hash = "${sha256(file("${path.module}/js/package.json"))}"
  }

  provisioner "local-exec" {
    command = "npm install"
    working_dir = "${path.module}/js"
  }
  
}