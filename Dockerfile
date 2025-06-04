FROM ruby:3.2.2

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

# Add Node.js and Yarn (corepackを使用してyarnを有効化)
RUN apt-get update -qq && \
    apt-get install -y nodejs && \
    corepack enable && \
    rm -rf /var/lib/apt/lists/*

COPY . .

EXPOSE 3000

CMD ["bundle", "exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]
