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

# Build argsを受け取る
ARG RAILS_MASTER_KEY
ARG PGHOST
ARG PGUSER
ARG PGPASSWORD
ARG PGDATABASE

# Build argsを環境変数として設定
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
ENV PGHOST=${PGHOST}
ENV PGUSER=${PGUSER}
ENV PGPASSWORD=${PGPASSWORD}
ENV PGDATABASE=${PGDATABASE}

# bashシェルを使用するように設定
SHELL ["/bin/bash", "-c"]

# アセットプリコンパイル（本番環境用）
RUN echo "🔧 Starting asset precompilation process..." && \
    echo "Environment check:" && \
    echo "RAILS_ENV: production" && \
    echo "RAILS_MASTER_KEY: ${RAILS_MASTER_KEY:0:10}..." && \
    echo "PGHOST: $PGHOST" && \
    echo "PGUSER: $PGUSER" && \
    echo "PGDATABASE: $PGDATABASE" && \
    if [ -f config/database.yml ]; then cp config/database.yml config/database_original.yml; else echo "⚠️ database.yml not found, skipping backup"; fi && \
    if [ -f config/database_precompile.yml ]; then cp config/database_precompile.yml config/database.yml; echo "📁 Database configuration swapped for precompilation"; else echo "⚠️ database_precompile.yml not found, using original database.yml"; fi && \
    RAILS_ENV=production \
    RAILS_MASTER_KEY=$RAILS_MASTER_KEY \
    PGHOST=$PGHOST \
    PGUSER=$PGUSER \
    PGPASSWORD=$PGPASSWORD \
    PGDATABASE=$PGDATABASE \
    SECRET_KEY_BASE_DUMMY=1 \
    bundle exec rails assets:precompile && \
    echo "✅ Asset precompilation completed successfully" && \
    if [ -f config/database_original.yml ]; then cp config/database_original.yml config/database.yml; echo "📁 Original database configuration restored"; else echo "⚠️ database_original.yml not found, keeping current configuration"; fi

# Production stage
FROM ruby:3.2.2-slim AS production

# Build argsを再度受け取る（production stageで使用するため）
ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}

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
CMD ["bash", "-c", "bundle exec rails db:migrate && bundle exec puma -C config/puma.rb"]# Cache bust #午後
