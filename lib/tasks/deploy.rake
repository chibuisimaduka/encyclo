namespace :git do
  task :pull do
    `git pull`
  end
end

task :deploy => ["git:pull", "assets:precompile"] do
  `sudo /opt/nginx/sbin/nginx -s stop`
  `sudo /opt/nginx/sbin/nginx`
end
