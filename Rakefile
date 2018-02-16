require 'dotenv/load'

namespace :db do
  desc 'Run migrations'
  task :migrate, [:version] do |t, args|
    require 'sequel'
    Sequel.extension :migration
    db = Sequel.connect(ENV.fetch('DATABASE_CONNECTION'))
    puts 'Migrating to latest'
    Sequel::Migrator.run(db, 'db/migrations')
  end
end
