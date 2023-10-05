resource "aws_api_gateway_rest_api" "this" {
  name = var.rest_apigateway_name
}

resource "aws_api_gateway_resource" "this_resource" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "${var.rest_apigateway_path_resource}"
}

resource "aws_api_gateway_method" "this_method" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "this_integration" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.this_resource.id
  http_method             = aws_api_gateway_method.this_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_arn
}

resource "aws_api_gateway_deployment" "this_deployment" {
  depends_on  = [aws_api_gateway_integration.this_integration]
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = var.rest_api_deployment_stage_name
  lifecycle {
    create_before_destroy = true
  }

  variables = {
    deployed_at = timestamp()
  }  
}