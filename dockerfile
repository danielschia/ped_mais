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
    bundle config set --local without 'production' && \
    bundle install --no-cache --jobs 4

# Copy application code
COPY . .

# Regenerate binstubs in case they're different
RUN bundle binstubs --all

EXPOSE 3000

# Create entrypoint script to run migrations and start server
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
echo "Waiting for Postgres..."\n\
until pg_isready -h db -p 5432; do\n\
  sleep 2\n\
done\n\
\n\
echo "Database ready!"\n\
\n\
echo "Skipping migrations..."\n\
\n\
exec "$@"\n\
' > /app/docker-entrypoint.sh && chmod +x /app/docker-entrypoint.sh

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["/app/bin/rails", "s", "-b", "0.0.0.0"]