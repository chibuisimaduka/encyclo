job_type :cap,    "cd :path && RAILS_ENV=:environment bundle exec cap :task --silent :output" 

every 1.day do
  cap "deploy:db:backup"
end
