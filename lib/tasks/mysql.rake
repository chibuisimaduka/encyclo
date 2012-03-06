namespace :mysql do

  task :db_config do
    unless @env = ENV['RAILS_ENV']
      puts "No RAILS_ENV specified. Using development environment."
      @env = "development"
    end
    db_file = ENV['DB_FILE'] || File.join(File.dirname(__FILE__),"../../config/database.yml")
    @db = YAML::load(ERB.new(IO.read(db_file)).result)[@env]
  end
  
  desc "Dump the mysql db for RAILS_ENV to OUTPUT_FILE"
  task :dump => :db_config do
    raise "Missing OUTPUT_FILE" unless ENV['OUTPUT_FILE']
    `mysqldump -u #{@db['username']} --password='#{@db['password']}' #{@db['database']} | bzip2 -c > #{ENV['OUTPUT_FILE']}`
  end

  desc "Load the mysql db for RAILS_ENV from INPUT_FILE"
  task :load => :db_config do
    raise "Missing INPUT_FILE" unless ENV['INPUT_FILE']
    @filename = "#{ENV['INPUT_FILE'][0..ENV['INPUT_FILE'].rindex('.')-1]}.sql"
    `bunzip2 -c #{ENV['INPUT_FILE']} > #{@filename}`
    `mysql -u #{@db['username']} --password='#{@db['password']}' #{@db['database']} < #{@filename}`
    `rm #{@filename}`
  end

  desc "Save the development mysql dump to the backups directory. Load using mysql env < file."
  task :backup do
    ENV['OUTPUT_FILE'] = "backups/sorted_development_backup_#{Time.now.to_i}_#{(ENV["MSG"] || "").gsub(" ", "_")}.bz2"
    Rake::Task["mysql:dump"].invoke
  end

end
