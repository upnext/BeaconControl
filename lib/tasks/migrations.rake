task :reload_migration_paths do
 ActiveRecord::Migrator.migrations_paths = Rails.application.paths['db/migrate'].to_a
end

task "db:migrate" => :reload_migration_paths
