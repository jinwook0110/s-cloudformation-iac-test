#!/usr/bin/env python3
import boto3
import sys
import os

def empty_bucket(bucket_name):
    print(f"バケット {bucket_name} のすべてのオブジェクトとバージョンを削除します...")
    s3_client = boto3.client('s3')
    
    try:
        # バケット内のすべてのバージョンとマーカーを取得
        versions = s3_client.list_object_versions(Bucket=bucket_name)
        
        # 通常のバージョンを削除
        if 'Versions' in versions and versions['Versions']:
            print(f"{len(versions['Versions'])} 個のバージョンを削除中...")
            for version in versions['Versions']:
                s3_client.delete_object(
                    Bucket=bucket_name,
                    Key=version['Key'],
                    VersionId=version['VersionId']
                )
        
        # 削除マーカーを削除
        if 'DeleteMarkers' in versions and versions['DeleteMarkers']:
            print(f"{len(versions['DeleteMarkers'])} 個の削除マーカーを削除中...")
            for marker in versions['DeleteMarkers']:
                s3_client.delete_object(
                    Bucket=bucket_name,
                    Key=marker['Key'],
                    VersionId=marker['VersionId']
                )
                
        print(f"バケット {bucket_name} のクリーンアップが完了しました。")
        return True
        
    except Exception as e:
        print(f"エラーが発生しました: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("使用方法: python empty_s3_bucket.py <バケット名>")
        sys.exit(1)
    
    bucket_name = sys.argv[1]
    success = empty_bucket(bucket_name)
    sys.exit(0 if success else 1)
