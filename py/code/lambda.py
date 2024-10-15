import json
import os
from boto3 import resource
import requests
import time

s3_client = resource('s3')
bucket_name = os.environ['MESSAGES_BUCKET']

def handler(event, context):
    
    # print the requests version:
    print(requests.__version__)

    try:
        method = event['httpMethod']
        
        if method == 'GET':
            return handle_get(event)
        elif method == 'POST':
            return handle_post(event)
        else:
            return {
                'statusCode': 405,
                'body': json.dumps('Method Not Allowed')
            }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(str(e))
        }
    



def handle_get(event):
    
    # list all objects in the bucket
    bucket = s3_client.Bucket(bucket_name)
    objects = bucket.objects.all()

    # send the list of objects as response
    messages = [obj.key for obj in objects]
    return {
        'statusCode': 200,
        'body': json.dumps(messages)
    }


    
def handle_post(event):
    
    if 'body' in event:
        body = json.loads(event['body'])
        # put the body in the bucket
        bucket = s3_client.Bucket(bucket_name)
        key = int(time.time() * 1000) + '.json'
        bucket.put_object(Key=key, Body=body['message'])
        return {
            'statusCode': 200,
            'body': json.dumps('POST request handled')
        }        

    return {
        'statusCode': 400,
        'body': json.dumps('Request body is missing')
    }
