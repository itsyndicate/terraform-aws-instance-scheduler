data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/function"
  output_path = "aws-lambda-function.zip"
}

resource "aws_lambda_function" "instance_scheduler" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
  function_name    = "aws_instance_scheduler"
  role             = aws_iam_role.lambda_role.arn
  handler          = "aws-lambda-function.lambda_handler"
  runtime          = "python3.8"
  timeout          = 10

  environment {
    variables = {
      TAG_NAME = var.schedule_tag_name
      TABLE_NAME = aws_dynamodb_table.schedule.name
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.instance_scheduler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_five_minutes.arn
}

resource "aws_cloudwatch_event_rule" "every_five_minutes" {
  name                = "${local.prefix}-LambdaScheduler"
  description         = "Fires every five minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "invoke_lambda_every_five_minutes" {
  rule      = aws_cloudwatch_event_rule.every_five_minutes.name
  target_id = "invoke_lambda_function"
  arn       = aws_lambda_function.instance_scheduler.arn
}

resource "aws_dynamodb_table" "schedule" {
  name           = "InstanceSchedulerConfig"  
  hash_key       = "ScheduleId"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "ScheduleId"
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "work_hours_schedule" {
  table_name = aws_dynamodb_table.schedule.name
  hash_key   = aws_dynamodb_table.schedule.hash_key

  item = <<ITEM
{
  "ScheduleId": {"S": "WorkHoursScheduleId"},
  "begintime": {"S": "08:00"},
  "endtime": {"S": "18:00"},
  "name": {"S": "WorkHoursSchedule"},
  "timezone": {"S": "Europe/Kyiv"},
  "type": {"S": "period"},
  "weekdays": {"SS": ["fri", "mon", "thu", "tue", "wed"]}
}
ITEM
}


resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.instance_scheduler.function_name}"
  retention_in_days = var.log_retention_days
}