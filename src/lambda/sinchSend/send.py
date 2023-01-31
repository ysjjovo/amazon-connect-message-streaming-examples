import boto3
import csv
from jinja2 import Template

s3=boto3.client('s3')
def lambda_handler(event, context):
    for r in event['Records']:
        bucket = r['s3']['bucket']['name']
        key = r['s3']['object']['key']
        # bucket = 'sms-to-send'
        # key = '2023-01-31/message.csv'
        recList = []
        input= s3.get_object(Bucket=bucket, Key=key)
        recList = input['Body'].read().decode("utf-8").split('\n')
        csv_reader = csv.reader(recList, delimiter=',', quotechar='"')
        exists = {}
        first=True
        header = {}
        for row in csv_reader:
            if first:
                first=False
                i = 0
                for col in row:
                    header[i] = col
                    i = i + 1
                continue
            print('header', header)
            if len(row) == 0: #emply row
                continue
            sender = row[0]
            to = row[1]
            content = row[2]
            vars = {}
            for i in range(3, len(row)):
                vars[header[i]] = row[i]
            content = Template(content).render(vars)
            print('content', content)
            # invoke api to send