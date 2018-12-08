FROM ruby:2.5.3-alpine3.8
RUN apk update && apk add --update build-base postgresql-dev nodejs tzdata
RUN mkdir /SimpleFormWithDocker
WORKDIR /SimpleFormWithDocker
COPY Gemfile /SimpleFormWithDocker/Gemfile
COPY Gemfile.lock /SimpleFormWithDocker/Gemfile.lock
RUN bundle install
COPY . /SimpleFormWithDocker
