set :application, "cruise"
set :repository, "git@github.com:rubaidh/cruisecontrol.rb.git"

role :web, "ardbeg.rubaidh.com"
role :app, "ardbeg.rubaidh.com"
role :db,  "ardbeg.rubaidh.com", :primary => true

set :deploy_to, "/var/www/apps/cruise"
set :user, "cruise"
set :scm, :git
