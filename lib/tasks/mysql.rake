namespace :mysql do

  desc "Save the development mysql dump to the backups directory. Load using mysql env < file."
  task :backup do
    filename = "backups/sorted_development_backup_#{Time.now.to_i}_#{(ENV["MSG"] || "").gsub(" ", "_")}"
    `mysqldump -u root sorted_development > #{filename}.sql`
    `tar -cvjf #{filename}.tar.bz2 #{filename}.sql`
    `rm #{filename}.sql`
    puts "Succesfully saved to #{filename}.tar.bz2"
  end

end
