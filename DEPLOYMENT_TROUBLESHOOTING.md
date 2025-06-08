# Deployment Troubleshooting Guide

このガイドは、AWS ECS へのデプロイメント中に発生する可能性のある問題と解決策について説明します。

## 🔍 よくある問題と解決策

### 1. Asset Precompilation の失敗

#### 症状

```
Error during `bundle exec rails assets:precompile`
Missing RAILS_MASTER_KEY or database connection issues
```

#### 原因

- GitHub Secrets の設定不備
- 環境変数の未設定
- データベース設定ファイルの問題

#### 解決策

**Step 1: GitHub Secrets の確認**
Repository Settings → Secrets and variables → Actions で以下が設定されているか確認：

- `RAILS_MASTER_KEY`
- `PGHOST`
- `PGUSER`
- `PGPASSWORD`
- `PGDATABASE`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

**Step 2: ローカルテスト**

```bash
# 環境変数を設定
export RAILS_MASTER_KEY=your_master_key
export PGHOST=your_db_host
export PGUSER=your_db_user
export PGPASSWORD=your_db_password
export PGDATABASE=your_db_name

# テストスクリプト実行
./scripts/test_asset_precompile.sh
```

**Step 3: RAILS_MASTER_KEY の再生成**

```bash
# 新しいマスターキーを生成
bundle exec rails credentials:edit
# 表示されたキーをGitHub Secretsに設定
```

### 2. Docker Build の失敗

#### 症状

```
Failed to build Docker image
Shell syntax errors or missing files
```

#### 解決策

**Dockerfile の確認**

- `SHELL ["/bin/bash", "-c"]` が設定されているか
- `ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}` が設定されているか
- ファイル存在チェックが適切に実装されているか

### 3. ECS Deploy の失敗

#### 症状

```
ECS service update failed
Task definition registration issues
```

#### 解決策

**AWS 設定の確認**

- ECR repository が存在するか
- ECS cluster と service が正しく設定されているか
- IAM 権限が適切に設定されているか

## 🛠️ デバッグ用コマンド

### ローカル環境でのテスト

```bash
# Asset precompilation テスト
./scripts/test_asset_precompile.sh

# Docker build テスト（環境変数を設定後）
docker build \
  --build-arg RAILS_MASTER_KEY=$RAILS_MASTER_KEY \
  --build-arg PGHOST=$PGHOST \
  --build-arg PGUSER=$PGUSER \
  --build-arg PGPASSWORD=$PGPASSWORD \
  --build-arg PGDATABASE=$PGDATABASE \
  -t test-image .
```

### AWS リソースの確認

```bash
# ECR repository の確認
aws ecr describe-repositories --repository-names portfolio-rails-production

# ECS cluster の確認
aws ecs describe-clusters --clusters portfolio-rails-production

# ECS service の確認
aws ecs describe-services \
  --cluster portfolio-rails-production \
  --services portfolio-rails-production-service
```

## 📊 ログの確認方法

### GitHub Actions

- Actions タブでワークフローの実行状況を確認
- 失敗したステップのログを詳細に確認

### ECS/CloudWatch

```bash
# ECS タスクのログ確認
aws logs get-log-events \
  --log-group-name /ecs/portfolio-rails-production \
  --log-stream-name <log-stream-name>
```

## 🔧 緊急時の対応

### デプロイメント停止

```bash
# ECS service のタスク数を0に設定
aws ecs update-service \
  --cluster portfolio-rails-production \
  --service portfolio-rails-production-service \
  --desired-count 0
```

### ロールバック

```bash
# 前のバージョンにロールバック
aws ecs update-service \
  --cluster portfolio-rails-production \
  --service portfolio-rails-production-service \
  --task-definition <previous-task-definition-arn>
```

## 📞 サポート

問題が解決しない場合は、以下の情報を含めてサポートに連絡：

- エラーメッセージの完全なログ
- 使用している環境の詳細
- 実行したトラブルシューティング手順
