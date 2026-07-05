# Use the official Ruby image as the base
FROM docker.io/library/ruby:3.3.11-slim AS base

# Install system dependencies for building gems and running the app
# libcurl4-openssl-dev is required for the 'typhoeus' gem (via 'ethon')
RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    build-essential \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock to install dependencies first
COPY Gemfile Gemfile.lock ./

# Upgrade Bundler and install the Ruby dependencies
RUN gem update --system && gem install bundler -v 2.7.2 && bundle install

# Copy the rest of the application code
COPY . .

FROM docker.io/library/ruby:3.3.11-slim

# Install runtime dependencies (libcurl4 is needed for typhoeus/ethon)
RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    libcurl4 \
    libjemalloc2 \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/lib/*-linux-gnu/libjemalloc.so.2 /usr/lib/libjemalloc.so.2

# For security reasons run the app as user 'ruby' not 'root'
RUN useradd ruby --create-home --shell /bin/bash

# Set the working directory inside the container
WORKDIR /app

# Copy the installed gems from the builder stage
COPY --from=base /usr/local/bundle /usr/local/bundle

# Copy the application code from the builder stage
COPY --from=base --chown=ruby:ruby /app /app

USER ruby

# Set production environment for Rack
ENV RACK_ENV="production"

# Tell the system to preload jemalloc before the standard glibc allocator
ENV LD_PRELOAD="/usr/lib/libjemalloc.so.2"

# Expose the port the app will be listening on (default in puma.rb is 3000)
EXPOSE 3000

# Set the default command to run the application using Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
