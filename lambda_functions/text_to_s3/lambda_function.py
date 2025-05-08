import boto3
import os
import json
from datetime import datetime

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    bucket_name = os.environ['BUCKET_NAME']
    
    # 現在時刻を含むテキストファイルを作成
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    content = f"This file was created by Lambda at {current_time}"
    
    # S3にファイルをアップロード
    file_name = f"text_file_{datetime.now().strftime('%Y%m%d%H%M%S')}.txt"
    s3.put_object(
        Bucket=bucket_name,
        Key=file_name,
        Body=content
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': f'File {file_name} uploaded to {bucket_name}',
            'bucket': bucket_name,
            'file': file_name
        })
    }
