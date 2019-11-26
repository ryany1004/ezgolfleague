FROM ruby:2.5.3 as builder

# Create a Docker image for running the app
#
# To build image:
#  - checkout code
#  - build docker image from source directory:  docker build Docker/Dockerfile -t <ezgolf:version>

# NOTE: we should upgrade to ruby 2.5.7 to use "ruby:2.5.7-buster" image instead
#
# nightmare to install node/yarn on ruby:2.5.3 image as it's Debian stretch
# which has ancient version of node (4.8.2).  most of this could be avoided
# by using "ruby:2.5.7-buster"  which includes node 10.15, but that for later...

# needed because of above, also need this installed first
RUN apt-get update && apt-get install -y apt-transport-https

# get recent repo for node 10.15
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

# Get repo for yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && apt-get install -y \
    httpie \
    nodejs \
    postgresql-client \
    yarn

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir /app
WORKDIR /app
COPY Gemfile /app
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install --jobs 6
COPY . /app

ENV RAILS_ENV="development" 

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-p", "3000", "-b", "0.0.0.0"]