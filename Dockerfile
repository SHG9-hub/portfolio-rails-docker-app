# Build stage
FROM ruby:3.2.2-slim AS builder

# 必要なパッケージのインストール
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    curl \
    git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# GemfileをコピーしてBundle install
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install

# アプリケーションコードをコピー
COPY . .

# アセットプリコンパイル（本番環境用）
# credentialsを一時的にリネームしてアセットプリコンパイル実行
RUN cp config/database.yml config/database_original.yml && \
    cp config/database_precompile.yml config/database.yml && \
    mv config/credentials.yml.enc config/credentials.yml.enc.bak && \
    echo "{}" > config/credentials.yml.enc && \
    RAILS_ENV=production \
    SECRET_KEY_BASE=dummysecretkeythatissixteenbyteslong \
    RAILS_MASTER_KEY=dummymasterkeythatissixteenbytes \
    DISABLE_SPRING=true \
    bundle exec rails assets:precompile --trace && \
    mv config/credentials.yml.enc.bak config/credentials.yml.enc && \
    cp config/database_original.yml config/database.yml

# Production stage
FROM ruby:3.2.2-slim AS production

# ランタイム依存パッケージのみインストール
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    libpq5 \
    curl && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -r rails && useradd -r -g rails rails

WORKDIR /app

# Gemをコピー
COPY --from=builder /usr/local/bundle /usr/local/bundle

# アプリケーションとプリコンパイルされたアセットをコピー
COPY --from=builder --chown=rails:rails /app .

# 非rootユーザーに切り替え
USER rails

# ヘルスチェック
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

EXPOSE 3000

# マイグレーション実行後にサーバー起動
CMD ["sh", "-c", "bundle exec rails db:migrate && bundle exec puma -C config/puma.rb"]