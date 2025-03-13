# Steps to run the project

## Install Ruby, bundle, git, Postgresql

## Clone this repo

## install dependencies for project
bundle install

## Configure the database 
Create Postgres Database for project, Postgres User with all privileges on database

Create .env file from .env.example with correct credentials for database

## create database and run migrations
rails db:drop db:create db:migrate

## Run specs to ensure in correct working
bundle exec rspec

## Run server 
rails server
