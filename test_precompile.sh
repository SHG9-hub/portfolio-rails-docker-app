#!/bin/bash

echo "🧪 ローカルでのアセットプリコンパイルテスト"
echo "==============================================="

# 環境変数の設定例（実際の値に置き換えてください）
export RAILS_ENV=production
export RAILS_MASTER_KEY=5617caf114236dd7d8a7916dcf54e874
export PGHOST=localhost
export PGUSER=postgres  
export PGPASSWORD=password
export PGDATABASE=portfoliorailsdb
export SECRET_KEY_BASE_DUMMY=1

echo "🔧 設定ファイルをバックアップ"
cp config/database.yml config/database_original.yml

echo "🔧 プリコンパイル用設定に切り替え"
cp config/database_precompile.yml config/database.yml

echo "🚀 アセットプリコンパイル実行"
bundle exec rails assets:precompile

if [ $? -eq 0 ]; then
    echo "✅ アセットプリコンパイル成功"
else
    echo "❌ アセットプリコンパイル失敗"
fi

echo "🔧 元の設定ファイルを復元"
cp config/database_original.yml config/database.yml

echo "🧹 テスト用ファイルを削除"
rm config/database_original.yml

echo "テスト完了！" 