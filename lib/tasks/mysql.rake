namespace :mysql do

  desc "Save the mysql dump to the backups directory. Load using mysql env < file."
  task :backup do
    filename = "backups/encyclo_production_backup_#{Time.now.to_i}_#{(ENV["MSG"] || "").gsub(" ", "_")}"
    `mysqldump -u root encyclo_production > #{filename}.sql`
    `tar cvjf #{filename}.tar.bz2 #{filename}.sql`
    `rm #{filename}.sql`
    puts "Succesfully saved to #{filename}.tar.bz2"
  end

  desc "Transfer the data from production to development."
  task :transfer do
    filename = "/tmp/transfer_encyclo_db_dev"
    `mysqldump -u root encyclo_production > #{filename}`
    `mysql -u root sorted_development < #{filename}`
    `rm #{filename}`
  end

end
