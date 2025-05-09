# CloudFormation IaC プロジェクト

このリポジトリは、AWS CloudFormationを使用したInfrastructure as Code（IaC）のデモプロジェクトです。

## 含まれるリソース

- S3バケット
- Lambda関数（3つ）
- Step Functions ステートマシン
- EC2インスタンス（Amazon Linux 2, t2.micro）

## 開発フロー

1. **新機能開発**:
   ```bash
   git checkout -b feature/your-feature-name
   # 変更を加える
   git add .
   git commit -m "機能の説明"
   git push origin feature/your-feature-name