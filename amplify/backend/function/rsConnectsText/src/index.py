from urllib import request, parse
import urllib
import os
import json
import base64
import boto3
import uuid
from datetime import datetime
from boto3.dynamodb.conditions import Key, Attr
import random
import ast

tableName = os.environ['STORAGE_RSCONNECTSARNSTORAGE_NAME']
dynamodb = boto3.resource('dynamodb')
arnData = dynamodb.Table(tableName)

sns = boto3.client('sns')

def handler(event, context):
  print('received event:')
  print(event)
  body = json.loads(event['body'])
  print(body['tokens'])
  print(body['message'])
  for token in ast.literal_eval(body['tokens']):
    response = getARNInfo(token)
    print(response)
    if len(response['Items']) == 0:
        platformResponse = sns.create_platform_endpoint(
            PlatformApplicationArn='arn:aws:sns:us-east-1:417990662395:app/APNS/RSConnects-PN',
            Token=token,
        )
        arn = platformResponse['EndpointArn']
        addARNInfo(token, arn)
    else:
        arn = response['Items'][0]['arn']
    print(arn)
    print(token)
    response = sns.publish(
        TargetArn=arn,
        Message=body['message']
    )
    print(response)

  return {
      'statusCode': 200,
      'headers': {
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
      },
      'body': json.dumps(response)
  }

def addARNInfo(token, arn):
    response = arnData.put_item(
        Item={
            'token': token,
            'arn': arn
        }
    )
    return response

def getARNInfo(token):
    response = arnData.query(KeyConditionExpression=Key('token').eq(token))
    return response
