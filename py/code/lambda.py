import json
import requests


def main(event, context):

    # print the requests version:
    print(requests.__version__)

    return {
        'statusCode': 400,
        'body': json.dumps('Hello from Lambda!')
    }