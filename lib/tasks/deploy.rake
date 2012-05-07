task :ensure_working_directory_clean do
  diff = `git status --porcelain`
  abort "There are uncommitted changes. Please commit or stash before deploying." unless diff.blank?
end

desc 'Deploy the app to Heroku'
task :deploy => %w{ensure_working_directory_clean test} do
  puts "Pushing to Heroku..."
  sh "git push heroku master"
end

namespace :deploy do
  desc 'Deploy the app to Heroku, then run migrations (and restart)'
  task :migrate => :deploy do
    puts "Running migrations..."
    sh "heroku run rake db:migrate"

    puts "Restarting app..."
    sh "heroku restart"

    puts "Done"
  end
end
