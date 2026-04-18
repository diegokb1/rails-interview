FROM ruby:3.2-slim

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libsqlite3-dev \
      nodejs \
      curl \
      redis-server && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY . .

# Precompile bootsnap
RUN bundle exec bootsnap precompile --gemfile app/ lib/

# Expose port
EXPOSE 3000

# Prepare DB and start server
CMD ["sh", "-c", "redis-server --daemonize yes && bundle exec rails db:prepare && bundle exec sidekiq & bundle exec rails server -b 0.0.0.0"]
