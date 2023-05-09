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

tableName = os.environ['STORAGE_RSCONNECTSUSERDATASTORAGE_NAME']
dynamodb = boto3.resource('dynamodb')
tableUserData = dynamodb.Table(tableName)

def handler(event, context):
    print('received event:')
    print(event)
    if 'GET' in event['httpMethod']:
        print(list(event['queryStringParameters'].keys())[list(event['queryStringParameters'].values()).index('')])
        response = getUserInfo(list(event['queryStringParameters'].keys())[list(event['queryStringParameters'].values()).index('')])
        print(response)
    if 'POST' in event['httpMethod']:
        body = json.loads(event['body'])
        response = addUserInfo(body['id'], body['email'], body['phone'], body['username'], body['isAdmin'])
    if 'PUT' in event['httpMethod']:
        body = json.loads(event['body'])
        response = updateUserInfo(body['id'], body['email'], body['phone'], body['username'], body['isAdmin'])
 

  
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Headers': '*',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
        },
        'body': json.dumps(response)
    }

def addUserInfo(id, email, phone, username, isAdmin):
    response = tableUserData.put_item(
        Item={
            'id': id,
            'email': email,
            'phone': phone,
            'username': username,
            'isAdmin': isAdmin
        }
    )
    return response

def updateUserInfo(id, email, phone, username, isAdmin):
    response = tableUserData.delete_item(
        Key={
            'id': id,
        }
    )
    response = tableUserData.put_item(
        Item={
            'id': id,
            'email': email,
            'phone': phone,
            'username': username,
            'isAdmin': isAdmin
        }
    )
    return response

def getUserInfo(id):
    response = tableUserData.query(KeyConditionExpression=Key('id').eq(id))
    return response

