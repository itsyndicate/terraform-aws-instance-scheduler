variable "aws_region" {
    description = "The AWS region to deploy to"
    type = string
    default = "us-west-1"
}

variable "project" {
    description = "The name of the project"
    type = string
    default = "aws-instance-scheduler"
}

variable "environment_tag" {
    description = "The name of the environment: dev, stage, prod"
    type = string
    default = "dev"
}

variable "contact" {
    description = "The email address of the person responsible for this project"
    type = string
    default = "support@itsyndicate.org"
}

variable "log_retention_days" {
    description = "The number of days to retain log events"
    type = number
    default = 7
  
}

variable "schedule_tag_name" {
  description = "The name of the tag to use for scheduling"
  type = string
  default = "InSchedule"
}