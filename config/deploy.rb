$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, 'ruby-1.9.2-head@rails313'
set :rvm_type, :user

require "bundler/capistrano"

$:.unshift File.join(File.dirname(__FILE__), '../lib/')
require "capistrano_database"
require "capistrano_uploads"

load "deploy/assets"

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

set :application, "enyclo"
set :repository,  "git://github.com/pascalr/encyclo.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, "/var/www/encyclo"

set :user, "pascalr"
set :use_sudo, false

server "localhost", :app, :web, :db, :primary => true
#role :db,  "your slave db-server here"

ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa_admin")]

default_run_options[:env] = {'RAILS_ENV' => 'production'}

def run_rake(task, options={}, &block)
  command = "cd #{latest_release} && /usr/bin/env bundle exec rake #{task}"
  run(command, options, &block)
end

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
