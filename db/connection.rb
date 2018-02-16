require 'dotenv/load'
require 'sequel'

DB = Sequel.connect(ENV['DATABASE_CONNECTION'])
Sequel::Model.raise_on_save_failure = false
