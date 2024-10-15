resource "aws_apigatewayv2_integration" "lambda_hello" {
  api_id = aws_apigatewayv2_api.messages_api.id

  integration_uri    = aws_lambda_function.py_message_lambda.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "get_messages_route" {
  api_id = aws_apigatewayv2_api.messages_api.id

  route_key = "GET /messages"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_hello.id}"
}

resource "aws_apigatewayv2_route" "post_messages_route" {
  api_id = aws_apigatewayv2_api.messages_api.id

  route_key = "POST /messages"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_hello.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.py_message_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.messages_api.execution_arn}/*/*"
}

output "messages_base_url" {
  value = aws_apigatewayv2_stage.dev_stage.invoke_url
}
