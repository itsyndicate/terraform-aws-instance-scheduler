import boto3
from datetime import datetime
from dateutil import tz
import os

tag_name = os.environ['TAG_NAME']
table_name = os.environ['TABLE_NAME']

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name)

    response = table.get_item(Key={'ScheduleId': 'WorkHoursScheduleId'})
    schedule = response['Item']

    now = datetime.now(tz.gettz(schedule['timezone']))
    current_time = now.strftime('%H:%M')
    current_day = now.strftime('%a').lower()

    if schedule['begintime'] <= schedule['endtime']:
        in_schedule = schedule['begintime'] <= current_time <= schedule['endtime']
    else:
        in_schedule = not (schedule['endtime'] < current_time < schedule['begintime'])

    if in_schedule and current_day in schedule['weekdays']:
        ec2 = boto3.resource('ec2')
        instances = ec2.instances.filter(
            Filters=[{'Name': f'tag:{tag_name}', 'Values': ['true']}]
        )
        for instance in instances:
            instance.start()

        rds = boto3.client('rds')
        response = rds.describe_db_instances()
        for db in response['DBInstances']:
            if any(tag['Key'] == tag_name and tag['Value'] == 'true' for tag in db['TagList']):
                rds.start_db_instance(DBInstanceIdentifier=db['DBInstanceIdentifier'])
    else:
        ec2 = boto3.resource('ec2')
        instances = ec2.instances.filter(
            Filters=[{'Name': f'tag:{tag_name}', 'Values': ['true']}]
        )
        for instance in instances:
            instance.stop()

        rds = boto3.client('rds')
        response = rds.describe_db_instances()
        for db in response['DBInstances']:
            if any(tag['Key'] == tag_name and tag['Value'] == 'true' for tag in db['TagList']):
                if db['DBInstanceStatus'] == 'available':
                    rds.stop_db_instance(DBInstanceIdentifier=db['DBInstanceIdentifier'])

    return {
        'statusCode': 200,
        'body': 'EC2 and RDS instances state updated based on schedule'
    }