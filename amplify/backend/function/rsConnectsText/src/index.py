import json
import boto3
import sys
import os
import ast

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

def sendText(pn, message): 
    print(pn)
    print(message)
    try:
        client = boto3.client(
            "sns",
            aws_access_key_id=os.environ.get(''), 
            aws_secret_access_key=os.environ.get(''),
            region_name="us-east-1"
        )
        
        client.set_sms_attributes(
            attributes={
                'DefaultSMSType': 'Transactional',
                'DeliveryStatusSuccessSamplingRate': '100',
                'DefaultSenderID': 'CodeBriefly'
            }
        )
        
        response = client.publish(
            PhoneNumber="+1"+pn,
            Message=message
        ) 
        print(response)
    except:
        print('Error', sys.exc_info()[0])
