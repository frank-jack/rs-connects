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
import urllib3
import datetime

tableName = os.environ['STORAGE_RSCONNECTSARNSTORAGE_NAME']
dynamodb = boto3.resource('dynamodb')
arnData = dynamodb.Table(tableName)

tableName = os.environ['STORAGE_RSCONNECTSUSERDATASTORAGE_NAME']
dynamodb = boto3.resource('dynamodb')
tableUserData = dynamodb.Table(tableName)

sns = boto3.client('sns')

def handler(event, context):
  print('received event:')
  print(event)
  http = urllib3.PoolManager()
  response = http.request('GET', 'https://rodephshalom.org/wp-json/tribe/events/v1/events/', headers=urllib3.util.make_headers(user_agent= 'my-agent/1.0.1', basic_auth='abc:xyz'))
  print(response.status)
  data = response.data.decode("utf-8")
  print(data)
  userData = getAllUserInfo()['Items']
  for event in json.loads(data)['events']:
    strTime = ''
    if int(event['start_date_details']['hour']) < 12:
        strTime = str(int(event['start_date_details']['hour']))+':'+event['start_date_details']['minutes']+' AM'
    elif int(event['start_date_details']['hour']) == 12:
        strTime = event['start_date_details']['hour']+':'+event['start_date_details']['minutes']+' PM'
    elif int(event['start_date_details']['hour']) > 12:
        strTime = str(int(event['start_date_details']['hour'])-12)+':'+event['start_date_details']['minutes']+' PM'
    print(strTime)
    newHour = datetime.datetime.now().hour-4
    newDay = datetime.datetime.now().day
    if newHour < 0:
        newHour = newHour+24            
        newDay = newDay-1
    now = datetime.datetime(datetime.datetime.now().year, datetime.datetime.now().month, newDay, newHour, datetime.datetime.now().minute, datetime.datetime.now().second)
    start = datetime.datetime(int(event['start_date_details']['year']), int(event['start_date_details']['month']), int(event['start_date_details']['day']), int(event['start_date_details']['hour']), int(event['start_date_details']['minutes']), int(event['start_date_details']['seconds']))
    print(now)
    print(start)
    print((start-now).days)
    print(start.hour-now.hour)
    if (start-now).days == 1 and (start.hour-now.hour) == 0:
        for user in userData:
            token = user['token']
            if len(token) > 0:
                response = getARNInfo(token)
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
                    Message=event['title']+' at '+strTime+' Tomorrow'
                )
                print(response)
  
  return {
      'statusCode': 200,
      'headers': {
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
      },
      'body': json.dumps(data)
  }
    
def addARNInfo(token, arn):
    response = arnData.put_item(
        Item={
            'token': token,
            'arn': arn
        }
    )
    return response

def getAllARNInfo():
    response = arnData.scan()
    data = response['Items']
    while 'LastEvaluatedKey' in response:   
        response = arnData.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
        data.extend(response['Items'])
    return response

def getAllUserInfo():
    response = tableUserData.scan()
    data = response['Items']
    while 'LastEvaluatedKey' in response:   
        response = tableUserData.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
        data.extend(response['Items'])
    return response
