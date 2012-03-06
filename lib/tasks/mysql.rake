namespace :mysql do

  task :db_config do
    unless @env = ENV['RAILS_ENV']
      puts "No RAILS_ENV specified. Using devlopment environment."
      @env = "development"
    end
    db_file = ENV['DB_FILE'] || File.join(File.dirname(__FILE__),"../../config/database.yml")
    @db = YAML::load(ERB.new(IO.read(db_file)).result)[@env]
  end
  
  task :dump => :db_config do
    raise "Missing OUTPUT_FILE" unless ENV['OUTPUT_FILE']
    `mysqldump -u #{@db['username']} --password='#{@db['password']}' #{@db['database']} | bzip2 -c > #{ENV['OUTPUT_FILE']}`
  end

  task :load => :db_config do
    raise "Missing INPUT_FILENAME" unless ENV['INPUT_FILENAME']
    @filename = ENV['INPUT_FILENAME']
    `bunzip2 -c #{@filename}.bz2 > #{@filename}.sql`
    `mysql -u #{@db['username']} --password='#{@db['password']}' #{@db['database']} < #{@filename}.sql`
    `rm #{@filename}.sql`
  end

  desc "Save the development mysql dump to the backups directory. Load using mysql env < file."
  task :backup do
    ENV['OUTPUT_FILE'] = "backups/sorted_development_backup_#{Time.now.to_i}_#{(ENV["MSG"] || "").gsub(" ", "_")}.bz2"
    Rake::Task["mysql:dump"].invoke
  end

end
