def lambda_handler(event, context):
    # 1001から2000までの数字を生成
    numbers = list(range(1001, 2001))
    
    return {
        'statusCode': 200,
        'numbers': numbers,
        'count': len(numbers),
        'range': '1001-2000'
    }
