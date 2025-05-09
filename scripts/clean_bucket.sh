#!/bin/bash

# 使用方法: ./clean_bucket.sh <バケット名>
BUCKET_NAME=$1

if [ -z "$BUCKET_NAME" ]; then
  echo "使用方法: ./clean_bucket.sh <バケット名>"
  exit 1
fi

echo "S3バケット $BUCKET_NAME のすべてのバージョンとマーカーを削除中..."

# 一時ファイルを作成
TEMP_FILE=$(mktemp)

# バージョン一覧を取得
echo "バージョン一覧を取得中..."
aws s3api list-object-versions --bucket $BUCKET_NAME > $TEMP_FILE

# Pythonスクリプトでバケットを空にする
python3 << EOF_PYTHON
import json
import os
import subprocess
import sys

temp_file = '$TEMP_FILE'
bucket = '$BUCKET_NAME'

try:
    with open(temp_file, 'r') as f:
        data = json.load(f)
except Exception as e:
    print(f"エラー: ファイルの読み込みに失敗しました - {e}")
    sys.exit(1)

# バージョンを削除
if 'Versions' in data and data['Versions']:
    print(f"{len(data['Versions'])} 個のバージョンを削除中...")
    for version in data['Versions']:
        key = version.get('Key')
        version_id = version.get('VersionId')
        if key and version_id:
            print(f"削除: {key} (バージョン: {version_id})")
            cmd = ["aws", "s3api", "delete-object", 
                   "--bucket", bucket, 
                   "--key", key, 
                   "--version-id", version_id]
            subprocess.run(cmd, check=False)
else:
    print("バージョンが見つかりませんでした")

# 削除マーカーを削除
if 'DeleteMarkers' in data and data['DeleteMarkers']:
    print(f"{len(data['DeleteMarkers'])} 個の削除マーカーを削除中...")
    for marker in data['DeleteMarkers']:
        key = marker.get('Key')
        version_id = marker.get('VersionId')
        if key and version_id:
            print(f"削除マーカーを削除: {key} (バージョン: {version_id})")
            cmd = ["aws", "s3api", "delete-object", 
                   "--bucket", bucket, 
                   "--key", key, 
                   "--version-id", version_id]
            subprocess.run(cmd, check=False)
else:
    print("削除マーカーが見つかりませんでした")

print("バケットを空にする処理が完了しました")
EOF_PYTHON

# 通常のオブジェクトも削除
echo "残りのオブジェクトを削除中..."
aws s3 rm s3://$BUCKET_NAME --recursive

# 一時ファイルを削除
rm -f $TEMP_FILE

echo "バケット $BUCKET_NAME の削除処理が完了しました。"
