# config valid for current version and patch releases of Capistrano
#lock "~> 3.10.1"

set :application, "my_app_name"
set :repo_url, "git@example.com:me/my_repo.git"

set :use_sudo, false

set :rvm_ruby_version, '2.3.3'
set :rvm_custom_path, '/usr/share/rvm'

set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', 'config/environments/production.rb')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')
