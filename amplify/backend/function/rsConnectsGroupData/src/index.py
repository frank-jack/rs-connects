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

tableName = os.environ['STORAGE_RSCONNECTSGROUPSTORAGE_NAME']
dynamodb = boto3.resource('dynamodb')
tableGroupData = dynamodb.Table(tableName)

def handler(event, context):
    print('received event:')
    print(event)
    if 'GET' in event['httpMethod']:
        response = getAllGroupInfo()
        print(response)
    if 'POST' in event['httpMethod']:
        body = json.loads(event['body'])
        response = addGroupInfo(body['id'], body['name'])
    if 'PUT' in event['httpMethod']:
        body = json.loads(event['body'])
        response = updateGroupInfo(body['id'], body['name'])
    if 'DELETE' in event['httpMethod']:
        body = json.loads(event['body'])
        response = deleteGroupInfo(body['id'])
 

  
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Headers': '*',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
        },
        'body': json.dumps(response)
    }

def addGroupInfo(id, name):
    response = tableGroupData.put_item(
        Item={
            'id': id,
            'name': name
        }
    )
    return response

def updateGroupInfo(id, name):
    response = tableGroupData.delete_item(
        Key={
            'id': id,
        }
    )
    response = tableGroupData.put_item(
        Item={
            'id': id,
            'name': name
        }
    )
    return response

def getAllGroupInfo():
    response = tableGroupData.scan()
    data = response['Items']
    while 'LastEvaluatedKey' in response:   
        response = tableGroupData.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
        data.extend(response['Items'])
    return response

def deleteGroupInfo(id):
    response = tableGroupData.delete_item(
        Key={
            'id': id
        }
    )
    return response

