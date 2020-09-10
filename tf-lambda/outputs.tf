# Define the output variable for the lambda function
output "lambda_function" {
  description = "Lambda function"
  value = aws_lambda_function.greet_lambda.function_name
}