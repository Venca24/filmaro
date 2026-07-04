# Use the official Ruby image as the base
FROM ruby:3.1.2-slim

# Install system dependencies for building gems and running the app
# libcurl4-openssl-dev is required for the 'typhoeus' gem (via 'ethon')
RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    build-essential \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# For security reasons run the app as user 'ruby' not 'root'
RUN useradd ruby --create-home --shell /bin/bash && mkdir /app && chown ruby:ruby /app

# Set the working directory inside the container
WORKDIR /app

# Copy Gemfile and Gemfile.lock to install dependencies first (leverages Docker cache)
COPY --chown=ruby:ruby Gemfile Gemfile.lock ./

# Upgrade Bundler to match the version from Gemfile.lock exactly
RUN gem update --system && gem install bundler

# Install the Ruby dependencies
RUN bundle install

# Copy the rest of the application code
COPY --chown=ruby:ruby . .

USER ruby

# Sets production environment for Rack
ENV RACK_ENV="production"

# Expose the port the app will be listening on (default in puma.rb is 3000)
EXPOSE 3000

# Set the default command to run the application using Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
