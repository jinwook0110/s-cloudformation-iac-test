def lambda_handler(event, context):
    # 1から1000までの数字を生成
    numbers = list(range(1, 1001))
    
    return {
        'statusCode': 200,
        'numbers': numbers,
        'count': len(numbers),
        'range': '1-1000'
    }
