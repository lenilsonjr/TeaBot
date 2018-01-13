set :deploy_to, "/home/app"

role :app, %w{user@host}
role :web, %w{user@host}
role :db,  %w{user@host}
