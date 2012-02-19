task :deploy do
  `git checkout stable`
  `git rebase origin/master`
  `cd /var/www/encyclo`
  Rake::Task["assets:precompile"].run
  `sudo /opt/nginx/sbin/nginx -s stop`
  `sudo /opt/nginx/sbin/nginx`
  `git checkout master`
end
