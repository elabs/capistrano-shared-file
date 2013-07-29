require 'capistrano'

module Capistrano
  module SharedFile

    def self.load_into(configuration)
      configuration.load do

        def remote_path_to(file)
          File.join(shared_path, shared_file_dir, file)
        end

        set :shared_files,    %w(config/database.yml)
        set :shared_file_dir, 'files'

        namespace :shared_file do

          desc 'Generate remote directories for shared files.'
          task :setup, :except => { :no_release => true } do
            shared_files.each do |file|
              run "#{try_sudo} mkdir -p #{remote_path_to(File.dirname(file))}"
              run "#{try_sudo} chmod g+w #{remote_path_to(File.dirname(file))}" if fetch(:group_writable, true)
            end
          end
          after 'deploy:setup', 'shared_file:setup.'

          desc 'Upload shared files to server'
          task :upload, :except => { :no_release => true } do
            shared_files.each do |file|
              top.upload(file, remote_path_to(file), :via => :scp)
            end
          end

          desc 'Download shared files from server.'
          task :download, :except => { :no_release => true } do
            shared_files.each do |file|
              top.download(remote_path_to(file), file, :via => :scp)
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
    end

  end
end

if Capistrano::Configuration.instance
  Capistrano::SharedFile.load_into(Capistrano::Configuration.instance)
end
