task :deploy => "assets:precompile" do
  `/opt/nginx/sbin/nginx -s stop`
  `/opt/nginx/sbin/nginx`
end
