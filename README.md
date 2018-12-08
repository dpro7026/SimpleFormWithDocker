# Simple Form With Docker

A basic RoR app that uses:
Docker Compose, Postgres, PGAdmin, Rspec, Simplecov, Brakeman, Devise, PaperTrail, SimpleForm, Pagy

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

Requires `Docker` installed on your environment.

### Installing & Running

Installation uses Docker Compose:

```
docker-compose build
docker-compose up
docker-compose run web rails db:create
```
### Stopping the App

```
docker-compose down
```

## Testing

Testing with RSpec

## Step-by-step of Development

### Create the Rails App in a Docker Container
Prerequisite: Install Docker on your environment.</br>
Modified instructions from: [Docker Docs, Quickstart: Compose and Rails](https://docs.docker.com/compose/rails/#define-the-project)
</br>
Create a `Dockerfile` containing:
```
FROM ruby:2.5.3-alpine3.8
RUN apk update && apk add --update build-base postgresql-dev nodejs tzdata
RUN mkdir /SimpleFormWithDocker
WORKDIR /SimpleFormWithDocker
COPY Gemfile /SimpleFormWithDocker/Gemfile
COPY Gemfile.lock /SimpleFormWithDocker/Gemfile.lock
RUN bundle install
COPY . /SimpleFormWithDocker
```
And a `Gemfile` containing:
```
source 'https://rubygems.org'
gem 'rails', '~> 5.2.1'
```
Create an empty `Gemfile.lock`.</br>
Finally, describe the 3 services - web, postgres and pgadmin by creating a `docker-compose.yml` containing:
```
version: '3'
services:
  postgres:
    container_name: postgres_container
    image: postgres
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-postgres}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-postgres}
      PGDATA: /data/postgres
    volumes:
       - postgres:/data/postgres
    networks:
      - postgres
    restart: unless-stopped

  web:
    container_name: web_container
    build: .
    command: bundle exec rails s -p 3000 -b '0.0.0.0'
    volumes:
      - .:/SimpleFormWithDocker
    ports:
      - "3000:3000"
    depends_on:
      - postgres
    networks:
      - postgres

  pgadmin:
    container_name: pgadmin_container
    image: dpage/pgadmin4
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_DEFAULT_EMAIL:-pgadmin4@pgadmin.org}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_DEFAULT_PASSWORD:-admin}
    volumes:
       - pgadmin:/root/.pgadmin
    ports:
      - "${PGADMIN_PORT:-5050}:80"
    networks:
      - postgres
    restart: unless-stopped

networks:
  postgres:
    driver: bridge

volumes:
    postgres:
    pgadmin:
    web:
```
Build the rails skeleton app with:
```
docker-compose run web rails new . --force --database=postgresql
```
This will update the `Gemfile` and we need to rebuild the docker file:
```
docker-compose build
```
Connect the database by replacing the contents of `config/database.yml` with:
```
default: &default
  adapter: postgresql
  encoding: unicode
  host: postgres
  username: postgres
  password: postgres
  pool: 5

development:
  <<: *default
  database: simpleformwithdocker_development

test:
  <<: *default
  database: simpleformwithdocker_test
```
Boot the web app with:
```
docker-compose up
```
View the web app at *localhost:3000* but note the error that the development database doesn't exist.</br>
Now create the database:
```
docker-compose run web rails db:create
```
Visit *localhost:3000* and see the skeleton Rails app is running.</br>
Note: To stop the app use `docker-compose down` and restart it with `docker-compose up`</br>
Check PGAdmin is functional at *localhost:5050* and login using the username and password in the `docker-compose.yml`</br>

### Add RSpec Testing Framework for TDD
Add to the `Gemfile` into the group :development, :test do:
```
# Testing framework
gem 'rspec-rails'
```
Re-build the container after updating `Gemfile`:
```
docker-compose build
```
Generate the RSpec configuration:
```
docker-compose run web rails generate rspec:install
```
Ensure the correct version of RSpec is used:
```
docker-compose run web bundle binstubs rspec-core
```

Create a new folder `spec/features` and 3 new files:
`create_survey_spec.rb`, `delete_survey_spec.rb` and `edit_survey_spec.rb`.</br>
Let's begin TDD by adding a test scenario to `create_survey_spec.rb`:
```
require "rails_helper"

RSpec.feature "Creating Survey" do
  scenario "A user creates a new survey" do
    visit "/"

    click_link "New Survey"
    fill_in "Title", with: "What is your fave Pokemon?"
    fill_in "Field 1", with: "Bulbasaur"
    fill_in "Field 2", with: "Squirtle"
    fill_in "Field 3", with: "Charmander"
    click_button "Create Survey"

    expect(page).to have_content("Survey has been created")
    expect(page.current_path).to eq(surveys_path)
  end
end
```
To ensure test code coverage we add to the `Gemfile`:
```
group :test do
  ...
  # Code coverage
  gem 'simplecov', require: false
end
```
We don't want to upload the coverage reports to Git, so add to `.gitignore`:
```
#Ignore coverage files
coverage/*
```
At the top of `spec/spec_helper.rb`:
```
require 'simplecov'
SimpleCov.start 'rails' do
  # These filters are excluded from results
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/spec/'
  add_filter '/test/'
  add_filter do |source_file|
    source_file.lines.count < 5
  end
end
```
Now when you run RSpec you will see the code coverage and generate a report in the coverage folder.</br>
Let's use Brakeman for static analysis by adding to the `Gemfile`:
```
group :development do
  ...
  # Static security vulnerability analysis
  gem 'brakeman'
end
```
Now re-build:
```
docker-compose build
```
To run RSpec:
```
docker-compose run web rspec
```
To run Brakeman and store it's report in our coverage folder:
```
docker-compose run web brakeman -o coverage/brakeman_report
```

## Authors

**David Provest** - [LinkedIn](https://www.linkedin.com/in/davidjprovest/)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
