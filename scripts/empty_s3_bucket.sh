#!/bin/bash

# 使用方法: ./empty_s3_bucket.sh バケット名
BUCKET_NAME=$1

if [ -z "$BUCKET_NAME" ]; then
  echo "使用方法: ./empty_s3_bucket.sh バケット名"
  exit 1
fi

echo "S3バケット ${BUCKET_NAME} のすべてのバージョンとマーカーを削除します..."

# バージョンの取得と削除
echo "バージョンを取得中..."
aws s3api list-object-versions --bucket ${BUCKET_NAME} --query "Versions" --output json > /tmp/versions.json

if [ -s /tmp/versions.json ] && [ "$(cat /tmp/versions.json)" != "[]" ] && [ "$(cat /tmp/versions.json)" != "{}" ]; then
  echo "バージョンを削除中..."
  python3 -c '
import json
import sys
import subprocess

with open("/tmp/versions.json", "r") as f:
    versions = json.load(f)

if versions:
    for i in range(0, len(versions), 1000):  # S3 APIは一度に1000オブジェクト削除の制限あり
        batch = versions[i:i+1000]
        delete_json = {"Objects": [{"Key": v["Key"], "VersionId": v["VersionId"]} for v in batch]}
        with open("/tmp/delete_batch.json", "w") as f:
            json.dump(delete_json, f)
        
        print(f"バッチ削除: {i} - {i+len(batch)}")
        subprocess.run(["aws", "s3api", "delete-objects", "--bucket", sys.argv[1], "--delete", "file:///tmp/delete_batch.json"], check=False)

' ${BUCKET_NAME}
fi

# 削除マーカーの取得と削除
echo "削除マーカーを取得中..."
aws s3api list-object-versions --bucket ${BUCKET_NAME} --query "DeleteMarkers" --output json > /tmp/markers.json

if [ -s /tmp/markers.json ] && [ "$(cat /tmp/markers.json)" != "[]" ] && [ "$(cat /tmp/markers.json)" != "{}" ]; then
  echo "削除マーカーを削除中..."
  python3 -c '
import json
import sys
import subprocess

with open("/tmp/markers.json", "r") as f:
    markers = json.load(f)

if markers:
    for i in range(0, len(markers), 1000):  # S3 APIは一度に1000オブジェクト削除の制限あり
        batch = markers[i:i+1000]
        delete_json = {"Objects": [{"Key": m["Key"], "VersionId": m["VersionId"]} for m in batch]}
        with open("/tmp/delete_batch.json", "w") as f:
            json.dump(delete_json, f)
        
        print(f"バッチ削除: {i} - {i+len(batch)}")
        subprocess.run(["aws", "s3api", "delete-objects", "--bucket", sys.argv[1], "--delete", "file:///tmp/delete_batch.json"], check=False)

' ${BUCKET_NAME}
fi

# 通常のオブジェクトも念のため削除
echo "通常のオブジェクトを削除中..."
aws s3 rm s3://${BUCKET_NAME} --recursive --include "*" || true

echo "バケット内の内容が正常に削除されました。"
