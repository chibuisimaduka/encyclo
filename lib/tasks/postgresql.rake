namespace :postgres do

  desc "Dump the postgres db for RAILS_ENV to OUTPUT_FILE"
  task :dump => :db_config do
    raise "Missing OUTPUT_FILE" unless ENV['OUTPUT_FILE']
    `PGPASSWORD=#{@db['password']} pg_dump -h #{@db['host']} -U #{@db['username']} #{@db['database']} | bzip2 -c > #{ENV['OUTPUT_FILE']}`
  end

  desc "Load the postgres db for RAILS_ENV from INPUT_FILE"
  task :load => :db_config do
    raise "Missing INPUT_FILE" unless ENV['INPUT_FILE']
    @filename = "#{ENV['INPUT_FILE'][0..ENV['INPUT_FILE'].rindex('.')-1]}.sql"
    `bunzip2 -c #{ENV['INPUT_FILE']} > #{@filename}`
    `PGPASSWORD=#{@db['password']} psql -h #{@db['host']} -U #{@db['username']} -d #{@db['database']} < #{@filename}`
    `rm #{@filename}`
  end

  desc "Save the development postgres dump to the backups directory. Load using psql env < file."
  task :backup do
    ENV['OUTPUT_FILE'] = "backups/sorted_development_backup_#{Time.now.to_i}_#{(ENV["MSG"] || "").gsub(" ", "_")}.bz2"
    Rake::Task["postgres:dump"].invoke
  end

end
