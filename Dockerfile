FROM ruby:3.2

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y curl gnupg nodejs default-mysql-client && \
    mkdir -p /usr/share/keyrings && \
    curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarn-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/yarn-archive-keyring.gpg] https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && \
    apt-get install -y yarn && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle install

COPY . /app

CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails s -b 0.0.0.0"]
