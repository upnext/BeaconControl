namespace :notifications do
  task :start => :environment do
    system "bundle exec rpush stop -e #{ Rails.env }"
    system "bundle exec rpush start -e #{ Rails.env }"
  end

  task :stop => :environment do
    system "bundle exec rpush stop -e #{ Rails.env }"
  end
end