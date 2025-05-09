#!/bin/bash

# 使用方法: ./delete_stack.sh <スタック名>
STACK_NAME=$1

if [ -z "$STACK_NAME" ]; then
  echo "使用方法: ./delete_stack.sh <スタック名>"
  exit 1
fi

echo "CloudFormationスタック $STACK_NAME を削除します"

# スタックが存在するか確認
if ! aws cloudformation describe-stacks --stack-name $STACK_NAME > /dev/null 2>&1; then
  echo "スタック $STACK_NAME は存在しません"
  exit 0
fi

# S3バケット名を取得
BUCKET_NAME=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].Outputs[?OutputKey=='S3BucketName'].OutputValue" --output text)

if [ -n "$BUCKET_NAME" ]; then
  echo "関連するS3バケット $BUCKET_NAME を空にします"
  # clean_bucket.shスクリプトを呼び出す（存在する場合）
  if [ -f "./scripts/clean_bucket.sh" ]; then
    ./scripts/clean_bucket.sh $BUCKET_NAME
  else
    echo "警告: clean_bucket.shスクリプトが見つかりません。手動でバケットを空にしてください。"
  fi
fi

# スタックを削除
echo "スタックを削除中..."
aws cloudformation delete-stack --stack-name $STACK_NAME

echo "スタック削除の開始が完了しました。削除完了まで待機中..."
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME

if aws cloudformation describe-stacks --stack-name $STACK_NAME > /dev/null 2>&1; then
  echo "警告: スタックの削除が完了しませんでした。削除状態を確認してください。"
  aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].StackStatus" --output text
  exit 1
else
  echo "スタック $STACK_NAME の削除が完了しました。"
fi
