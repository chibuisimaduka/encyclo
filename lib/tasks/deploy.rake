task :deploy do
  `cd "/var/www/encyclo"`
  `git pull`
  Rake::Task["assets:precompile"].invoke
  `sudo /opt/nginx/sbin/nginx -s stop`
  `sudo /opt/nginx/sbin/nginx`
end
