set :application, "cruisecontrol.rb"
set :user, 'deploy'
set :use_sudo, false
set :host, "pat.powertochange.org"

set :scm, "git"
set :repository, "git://github.com/andrewroth/#{application}.git"
set :deploy_via, :remote_cache
set :deploy_to, "/var/www/cc.campusforchrist.org"
set :git_enable_submodules, false
set :git_shallow_clone, true

server host, :app, :web, :db, :primary => true
after "deploy", "deploy:cleanup"

namespace :deploy do
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is not applicable to Passenger"
    task t, :roles => :app do ; end
  end
end
