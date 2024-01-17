# Terraform AWS Instance Scheduler

[![SWUbanner](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner2-direct.svg)](https://github.com/vshymanskyy/StandWithUkraine/blob/main/docs/README.md)

This repository contains a Terraform configuration that creates resources on AWS to manage EC2 and RDS instances based on a schedule. This is useful for environments such as development or testing where resources are not needed outside of working hours, helping to reduce costs.

## Features

- Schedules the start and stop times of EC2 and RDS instances.
- Uses AWS Lambda functions to control the state of the instances.
- Stores the schedule in a DynamoDB table.
- Uses tags to identify which instances to control.

## Tagging

The system uses tags to identify which EC2 and RDS instances to start and stop based on the schedule. You should tag your instances with the key provided in var `schedule_tag_name` with the value `true` for them to be managed by the system.

## Usage

1. Clone this repository.
2. Update the variables in the `variables.tf` file as needed.
3. Run `terraform init` to initialize the backend and download the necessary providers.
4. Run `terraform apply` to create the resources on AWS.

Please note that you need to have AWS credentials set up on your machine to use this configuration. You can do this by setting the `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_REGION` environment variables, or by using the AWS CLI or SDKs.

## Support

If you encounter any issues or have any questions, please open an issue in this repository.