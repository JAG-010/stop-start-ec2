// Creating an AWS IAM role
resource "aws_iam_role" "stop_start_ec2_role" {
  name               = "stop_start_ec2_role"
  assume_role_policy = file("files/assumerolepolicy.json")
}

//Creating an AWS IAM policy
resource "aws_iam_policy" "stop_start_ec2_policy" {
  name        = "stop_start_ec2_policy"
  description = "policy to start and stop ec2 instances"
  policy      = file("files/policyec2startstop.json")
}

//Attaching the policy to the role
resource "aws_iam_policy_attachment" "stop_start_ec2_attach" {
  name       = "stop_start_ec2_attachment"
  roles      = ["${aws_iam_role.stop_start_ec2_role.name}"]
  policy_arn = aws_iam_policy.stop_start_ec2_policy.arn
}

// zip files for lambda
# resource "null_resource" "start-ec2-zip" {
#   provisioner "local-exec" {
#     command = "zip ./files/start-ec2.zip ./files/start-ec2.py"
#   }
# }
# 
# resource "null_resource" "stop-ec2-zip" {
#   provisioner "local-exec" {
#     command = " zip ./files/stop-ec2.zip ./files/stop-ec2.py"
#   }
# }

// Create lambda function
resource "aws_lambda_function" "lambda_stop_ec2" {
  # If the file is not in the current working directory you will need to include a 
  # path.module in the filename.
  filename      = "files/stop-ec2.zip"
  function_name = "stop-ec2-fn"
  role          = aws_iam_role.stop_start_ec2_role.arn
  handler       = "stop-ec2.lambda_handler"

  #depends_on = [null_resource.start-ec2-zip,
  #  null_resource.stop-ec2-zip,
  #]

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("files/stop-ec2.zip")

  runtime = "python3.9"

  #   environment {
  #     variables = {
  #       foo = "bar"
  #     }
  #   }
}

resource "aws_lambda_function" "lambda_start_ec2" {
  filename         = "files/start-ec2.zip"
  function_name    = "start-ec2-fn"
  role             = aws_iam_role.stop_start_ec2_role.arn
  handler          = "start-ec2.lambda_handler"
  source_code_hash = filebase64sha256("files/start-ec2.zip")
  runtime          = "python3.9"
}

// eventbridge rule
resource "aws_cloudwatch_event_rule" "StopEC2Instances" {
  name        = "StopEC2Instances"
  description = "StopEC2Instances"

  schedule_expression = "cron(47 1 ? * MON-FRI *)" #GMT
}

resource "aws_cloudwatch_event_target" "stop_ec2_lambda" {
  rule      = aws_cloudwatch_event_rule.StopEC2Instances.name
  target_id = "Trigger-stop-ec2-fn"
  arn       = aws_lambda_function.lambda_stop_ec2.arn
}

resource "aws_cloudwatch_event_rule" "StartEC2Instances" {
  name        = "StartEC2Instances"
  description = "StartEC2Instances"

  schedule_expression = "cron(52 1 ? * MON-FRI *)" #GMT
}

resource "aws_cloudwatch_event_target" "start_ec2_lambda" {
  rule      = aws_cloudwatch_event_rule.StartEC2Instances.name
  target_id = "Trigger-start-ec2-fn"
  arn       = aws_lambda_function.lambda_start_ec2.arn
}

resource "aws_lambda_permission" "allow_eventbridge_start-ec2" {
  statement_id  = "AllowExecutionFromEventbridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_start_ec2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.StartEC2Instances.arn
}

resource "aws_lambda_permission" "allow_eventbridge_stop-ec2" {
  statement_id  = "AllowExecutionFromEventbridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_stop_ec2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.StopEC2Instances.arn
}