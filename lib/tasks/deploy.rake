task :deploy do
  `git checkout stable`
  `git rebase origin/master`
  `git push`
  `cd /var/www/encyclo`
  `git pull`
  Rake::Task["assets:precompile"].run
  `sudo /opt/nginx/sbin/nginx -s stop`
  `sudo /opt/nginx/sbin/nginx`
  `git checkout master`
end
