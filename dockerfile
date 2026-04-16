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

ENV RAILS_ENV=production \
    BUNDLE_WITHOUT="development test"

COPY Gemfile Gemfile.lock ./

RUN gem update --system && \
    bundle install --jobs 4 --retry 3

# Copy app
COPY . .

# RUN bundle exec rake assets:precompile

# Binstubs
RUN bundle binstubs --all

EXPOSE 3000

# Entrypoint melhorado
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
echo "Running migrations..."\n\
bundle exec rails db:migrate\n\
\n\
exec "$@"\n\
' > /app/docker-entrypoint.sh && chmod +x /app/docker-entrypoint.sh

# ENTRYPOINT ["/app/docker-entrypoint.sh"]

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]