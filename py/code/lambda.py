import json

def main(event, context):
    return {
        'statusCode': 400,
        'body': json.dumps('Hello from Lambda!')
    }