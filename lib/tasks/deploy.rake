task :deploy => "assets:precompile" do
  `sudo /opt/nginx/sbin/nginx -s stop`
  `sudo /opt/nginx/sbin/nginx`
end
