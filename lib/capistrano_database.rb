Capistrano::Configuration.instance.load do
namespace :deploy do

  namespace :db do
    
    desc "Make a backup remotely."
    task :backup, :roles => :db, :only => {:primary => true}, :no_release => true do
      @filename = "encyclo_prod_#{Time.now.to_i}_#{(ENV["MSG"] || "").gsub(" ", "_")}"
      @file = (ENV["OUTPUT_FILE"] = "#{shared_path}/backups/#{@filename}.bz2")
      run_rake "postgres:dump OUTPUT_FILE=#{@file}"
    end

    desc "Make a backup remotely and fetch it."
    task :local_backup, :roles => :db, :only => {:primary => true}, :no_release => true do
      get @file, "./#{@filename}.bz2"
    end

    desc "Transfer data from production environment to local development environment."
    task :pull, :roles => :db, :only => {:primary => true}, :no_release => true do
      `bundle exec rake postgres:load INPUT_FILENAME=#{@filename}`
      `rm #{@filename}.bz2`
    end

    before "deploy:db:local_backup", "deploy:db:backup"
    before "deploy:db:pull",     "deploy:db:local_backup"

    desc "Push the development database to production."
    task :push, :roles => :db, :only => {:primary => true}, :no_release => true do 
      file = "/tmp/database_dump.bz2"
      `rake postgres:dump OUTPUT_FILE=#{file}`
      transfer(:up, file, file)
      run_rake "postgres:load"
    end

    #before "deploy:db:push", "deploy:db:backup"

    # Author::      Simone Carletti <weppos@weppos.net>
    # Link::        http://www.simonecarletti.com/
    # Source::      http://gist.github.com/2769
    desc <<-DESC
      Creates the database.yml configuration file in shared path.

      By default, this task uses a template unless a template \
      called database.yml.erb is found either is :template_dir \
      or /config/deploy folders. The default template matches \
      the template for config/database.yml file shipped with Rails.

      When this recipe is loaded, db:setup is automatically configured \
      to be invoked after deploy:setup. You can skip this task setting \
      the variable :skip_db_setup to true. This is especially useful \ 
      if you are using this recipe in combination with \
      capistrano-ext/multistaging to avoid multiple db:setup calls \ 
      when running deploy:setup for all stages one by one.
    DESC
    task :setup, :except => { :no_release => true } do

      default_template = <<-EOF
      base: &base
        adapter: sqlite3
        timeout: 5000
      development:
        database: #{shared_path}/db/development.sqlite3
        <<: *base
      test:
        database: #{shared_path}/db/test.sqlite3
        <<: *base
      production:
        database: #{shared_path}/db/production.sqlite3
        <<: *base
      EOF

      location = fetch(:template_dir, "config/deploy") + '/database.yml.erb'
      template = File.file?(location) ? File.read(location) : default_template

      config = ERB.new(template)

      run "mkdir -p #{shared_path}/db" 
      run "mkdir -p #{shared_path}/config" 
      put config.result(binding), "#{shared_path}/config/database.yml"
    end

    desc <<-DESC
      [internal] Updates the symlink for database.yml file to the just deployed release.
    DESC
    task :symlink, :except => { :no_release => true } do
      run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
    end

  end

  after "deploy:finalize_update", "deploy:db:symlink"

end
end
