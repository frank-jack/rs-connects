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

tableName = os.environ['STORAGE_RSCONNECTSPOSTSTORAGE_NAME']
dynamodb = boto3.resource('dynamodb')
tablePostData = dynamodb.Table(tableName)

def handler(event, context):
    print('received event:')
    print(event)
    if 'GET' in event['httpMethod']:
        response = getAllPostInfo()
        print(response)
    if 'POST' in event['httpMethod']:
        body = json.loads(event['body'])
        response = addPostInfo(body['id'], body['userId'], body['text'], body['groupId'], body['image'])
    if 'PUT' in event['httpMethod']:
        body = json.loads(event['body'])
        response = updatePostInfo(body['id'], body['userId'], body['text'], body['groupId'], body['image'])
 

  
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Headers': '*',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
        },
        'body': json.dumps(response)
    }

def addPostInfo(id, userId, text, groupId, image):
    response = tablePostData.put_item(
        Item={
            'id': id,
            'userId': userId,
            'text': text,
            'groupId': groupId,
            'image': image
        }
    )
    return response

def updatePostInfo(id, userId, text, groupId, image):
    response = tablePostData.delete_item(
        Key={
            'id': id,
        }
    )
    response = tablePostData.put_item(
        Item={
            'id': id,
            'userId': userId,
            'text': text,
            'groupId': groupId,
            'image': image
        }
    )
    return response

def getAllPostInfo():
    response = tablePostData.scan()
    data = response['Items']
    while 'LastEvaluatedKey' in response:   
        response = tablePostData.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
        data.extend(response['Items'])
    return response




