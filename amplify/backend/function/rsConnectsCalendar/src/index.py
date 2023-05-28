import json
import urllib3

tableName = os.environ['STORAGE_RSCONNECTSTOKENSTORAGE_NAME']
dynamodb = boto3.resource('dynamodb')
tokenTable = dynamodb.Table(tableName)

sns = boto3.client('sns')

def handler(event, context):
  print('received event:')
  print(event)
  http = urllib3.PoolManager()
  response = http.request('GET', 'https://rodephshalom.org/wp-json/tribe/events/v1/events/', headers=urllib3.util.make_headers(user_agent= 'my-agent/1.0.1', basic_auth='abc:xyz'))
  print(response.status)
  data = response.data.decode("utf-8")
  print(data)
  
  return {
      'statusCode': 200,
      'headers': {
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
      },
      'body': json.dumps(data)
  }

def createEndpoint(token): 
    
