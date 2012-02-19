namespace :mysql do

  desc "Save the mysql dump to the backups directory. Load using mysql env < file."
  task :backup do
    filename = "backups/sorted_development_backup_#{(ENV["MSG"] || "").gsub(" ", "_")}_#{Time.now.to_i}.sql"
    `mysqldump -u root sorted_development > #{filename}`
    puts "Succesfully saved to #{filename}"
  end

  desc "Transfer the data from production to development."
  task :transfer do
    filename = "/tmp/transfer_encyclo_db_dev"
    `mysqldump -u root encyclo_production > #{filename}`
    `mysql -u root sorted_development < #{filename}`
    `rm #{filename}`
  end

end
