provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  endpoints {
    apigateway = "http://localhost:4566"
  }
}

resource "aws_api_gateway_rest_api" "k8s_api" {
  name = "K8s API"
}

data "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.k8s_api.id
  path        = "/"
}

# Define GET method for the root resource to route to service-1
resource "aws_api_gateway_method" "get_root_service_1" {
  rest_api_id   = aws_api_gateway_rest_api.k8s_api.id
  resource_id   = data.aws_api_gateway_resource.root.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "service_1_integration" {
  rest_api_id             = aws_api_gateway_rest_api.k8s_api.id
  resource_id             = data.aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.get_root_service_1.http_method
  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://service-1.default.svc.cluster.local"  # Kubernetes DNS name for service-1

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

# Define GET method for another endpoint to route to service-2
resource "aws_api_gateway_method" "get_root_service_2" {
  rest_api_id   = aws_api_gateway_rest_api.k8s_api.id
  resource_id   = data.aws_api_gateway_resource.root.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "service_2_integration" {
  rest_api_id             = aws_api_gateway_rest_api.k8s_api.id
  resource_id             = data.aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.get_root_service_2.http_method
  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://service-2.default.svc.cluster.local"  # Kubernetes DNS name for service-2

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.k8s_api.id
  stage_name  = "test"
  depends_on  = [
    aws_api_gateway_integration.service_1_integration,
    aws_api_gateway_integration.service_2_integration
  ]
}