import json
import boto3
import sys
import os
import ast

tableName = os.environ['STORAGE_RSCONNECTSGROUPSTORAGE_NAME']
dynamodb = boto3.resource('dynamodb')
arnData = dynamodb.Table(tableName)

def handler(event, context):
  print('received event:')
  print(event)
  body = json.loads(event['body'])
  print(body['phoneNumbers'])
  print(body['message'])
  for pn in ast.literal_eval(body['phoneNumbers']):
    sendText(pn, body['message'])

  return {
      'statusCode': 200,
      'headers': {
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
      },
      'body': json.dumps('Hello from your new Amplify Python lambda!')
  }

        
