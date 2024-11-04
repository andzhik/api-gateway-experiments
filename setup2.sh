export AWS_ENDPOINT_URL=http://localhost:4566

# Create API Gateway and routes
api_id=$(aws apigateway create-rest-api --name "K8s API" --endpoint-url $AWS_ENDPOINT_URL | jq -r '.id')
resources=$(aws apigateway get-resources --rest-api-id $api_id --endpoint-url $AWS_ENDPOINT_URL | jq -r '.items[0].id')
aws apigateway put-method --rest-api-id $api_id --resource-id $resources --http-method GET --authorization-type "NONE" --endpoint-url $AWS_ENDPOINT_URL
aws apigateway put-integration --rest-api-id $api_id --resource-id $resources --http-method GET --type HTTP --integration-http-method GET --uri "http://service-1.default.svc.cluster.local"
