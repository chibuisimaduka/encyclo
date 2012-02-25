namespace :mysql do

  desc "Save the mysql dump to the backups directory. Load using mysql env < file."
  task :backup do
    filename = "backups/encyclo_production_backup_#{(ENV["MSG"] || "").gsub(" ", "_")}_#{Time.now.to_i}.sql"
    `mysqldump -u root encyclo_production -p > #{filename}`
    puts "Succesfully saved to #{filename}"
  end

  desc "Transfer the data from production to development."
  task :transfer do
    filename = "/tmp/transfer_encyclo_db_dev"
    `ssh root@216.221.55.87 'mysqldump -h 216.221.55.87 -u root encyclo_production -p > #{filename}'`
    `scp root@216.221.55.87:#{filename} #{filename}`
    `mysql -u root sorted_development < #{filename}`
    `rm #{filename}`
    `ssh root@216.221.55.87 'rm #{filename}'`
  end

end
