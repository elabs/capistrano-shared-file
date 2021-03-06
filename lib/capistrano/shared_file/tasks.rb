require 'capistrano'

unless Capistrano::Configuration.respond_to?(:instance)
  abort 'capistrano/shared_file requires Capistrano 2'
end

Capistrano::Configuration.instance.load do

  _cset :shared_files,          %w(config/database.yml)
  _cset :shared_file_dir,       'files'
  _cset :shared_file_local_dir, '.'
  _cset :shared_file_backup,    false

  def local_path_to(file)
    File.join(shared_file_local_dir, file)
  end

  def remote_path_to(file)
    File.join(shared_path, shared_file_dir, file)
  end

  def backup_path_to(file)
    File.join(File.dirname(file), "#{Time.now.strftime('%Y%m%dT%H%M%S')}_#{File.basename(file)}")
  end

  namespace :shared_file do

    desc 'Generate remote directories for shared files.'
    task :setup, :except => { :no_release => true } do
      shared_files.each do |file|
        run "#{try_sudo} mkdir -p #{remote_path_to(File.dirname(file))}"
        run "#{try_sudo} chmod g+w #{remote_path_to(File.dirname(file))}" if fetch(:group_writable, true)
      end
    end
    after 'deploy:setup', 'shared_file:setup'

    desc 'Upload shared files to server'
    task :upload, :except => { :no_release => true } do
      shared_files.each do |file|
        local_file = local_path_to(file)
        if shared_file_backup
          top.download(remote_path_to(file), backup_path_to(local_file), :via => :scp, :once => true)
        end
        top.upload(local_file, remote_path_to(file), :via => :scp)
      end
    end

    desc 'Download shared files from server.'
    task :download, :except => { :no_release => true } do
      shared_files.each do |file|
        local_file = local_path_to(file)
        if shared_file_backup
          run_locally "cp #{local_file} #{backup_path_to(local_file)}"
        end
        top.download(remote_path_to(file), local_file, :via => :scp, :once => true)
      end
    end

    desc 'Symlink remote shared files to the current release directory.'
    task :symlink, :except => { :no_release => true } do
      shared_files.each do |file|
        run "ln -nfs #{remote_path_to(file)} #{release_path}/#{file}"
      end
    end
    after 'deploy:finalize_update', 'shared_file:symlink'

  end

end
