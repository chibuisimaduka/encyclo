# ==============================
# Uploads
# ==============================

unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end

Capistrano::Configuration.instance.load do

  namespace :uploads do
  
    desc <<-EOD
      [internal] Creates the symlink to uploads shared folder
      for the most recently deployed version.
    EOD
    task :symlink, :except => { :no_release => true } do
      run "ln -nfs #{shared_path}/uploads #{release_path}/public/uploads"
    end
  
    after "deploy:finalize_update", "uploads:symlink"
  
  end

end
