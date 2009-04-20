set :application, "exhume"
set :user, application
set :use_sudo, false
set :host, "ardbeg.rubaidh.com"

set :scm, "git"
set :repository, "git@github.com:rubaidh/#{application}.git"
set :deploy_via, :remote_cache
set :git_enable_submodules, true

role :app, host
role :web, host
role :db,  host, :primary => true

namespace :deploy do
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is not applicable to Passenger"
    task t, :roles => :app do ; end
  end
end
