# Multi-stage build for minimal image size
FROM ruby:3.4-slim as builder

# Set working directory
WORKDIR /app

# Install system dependencies needed for building gems
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock* ./

# Install gems
RUN bundle install --without development test

# --------- Final Runtime Stage ---------
FROM ruby:3.4-slim

# Set working directory
WORKDIR /app

# Install runtime dependencies only
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN useradd -m -u 1000 runner && chown -R runner:runner /app

# Copy gems from builder stage
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Copy application code
COPY --chown=runner:runner . .

# Switch to non-root user
USER runner

# Set Ruby to not buffer output
ENV RUBY_RLWRAP=1
ENV BUNDLE_PATH=/usr/local/bundle

# Main executable is rest-run
ENTRYPOINT ["./bin/rest-run"]
CMD ["--help"]
