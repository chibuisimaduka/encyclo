$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, 'ruby-1.9.2-head@rails313'
set :rvm_type, :user

require "bundler/capistrano"

require "capistrano_database"

set :application, "enyclo"
set :repository,  "git://github.com/pascalr/encyclo.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, "/var/www/encyclo"

set :user, "pascalr"
set :use_sudo, false

role :web, "216.221.61.38"                          # Your HTTP server, Apache/etc
role :app, "216.221.61.38"                          # This may be the same as your `Web` server
role :db,  "216.221.61.38", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa_admin")]

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do
    run "#{try_sudo} /opt/nginx/sbin/nginx"
  end
  task :stop do
    run "if [ -s /opt/nginx/logs/nginx.pid ]; then #{try_sudo} /opt/nginx/sbin/nginx -s stop; fi"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "if [ -s /opt/nginx/logs/nginx.pid ]; then #{try_sudo} /opt/nginx/sbin/nginx -s stop; fi"
    run "#{try_sudo} /opt/nginx/sbin/nginx"
  end
end
