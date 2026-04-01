FROM ruby:3.2-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    libyaml-dev \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy Gemfile first for layer caching
COPY Gemfile Gemfile.lock ./

# Install gems
RUN gem update --system && \
    bundle config set --local deployment 'true' && \
    bundle install --no-cache --jobs 4

# Copy application code
COPY . .

# Regenerate binstubs in case they're different
RUN bundle binstubs --all

EXPOSE 3000

# Create entrypoint script to run migrations and start server
RUN echo '#!/bin/bash\nset -e\nbundle exec rails db:create\nbundle exec rails db:migrate\nexec "$@"' > /app/docker-entrypoint.sh && chmod +x /app/docker-entrypoint.sh

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["/app/bin/rails", "s", "-b", "0.0.0.0"]