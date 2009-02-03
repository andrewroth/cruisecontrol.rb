ActionMailer::Base.smtp_settings = {
  :address =>        "localhost",
  :domain =>         "rubaidh.com",
}

# Change how often CC.rb pings Subversion for new requests. Default is 10.seconds, which should be OK for a local
# SVN repository, but probably isn't very polite for a public repository, such as RubyForge. This can also be set for
# each project individually, through project.scheduler.polling_interval option:
Configuration.default_polling_interval = 1.minute

# How often the dashboard page refreshes itself. If you have more than 10-20 dashboards open,
# it is advisable to set it to something higher than the default 5 seconds:
Configuration.dashboard_refresh_interval = 1.minute

# Site-wide setting for the email "from" field. This can also be set on per-project basis,
# through project.email.notifier.from attribute
Configuration.email_from = 'noreply@rubaidh.com'

# Root URL of the dashboard application. Setting this attribute allows various notifiers to include a link to the
# build page in the notification message.
Configuration.dashboard_url = 'http://cruise.rubaidh.com/'

# If you don't want to allow triggering builds through dashboard Build Now button. Useful when you host CC.rb as a
# public web site (such as http://cruisecontrolrb.thoughtworks.com/projects - try clicking on Build Now button there
# and see what happens):
# Configuration.disable_build_now = true

# If you want to only allow one project to build at a time, uncomment this line
# by default, cruise allows multiple projects to build at a time
# Configuration.serialize_builds = true

# Amount of time a project will wait to build before failing when build serialization is on
# Configuration.serialized_build_timeout = 3.hours

# To delete build when there are more than a certain number present, uncomment this line - it will make the dashboard
# perform better
BuildReaper.number_of_builds_to_keep = 20

# any files that you'd like to override in cruise, keep in ~/.cruise, and copy over when this file is loaded like this
site_css = CRUISE_DATA_ROOT + "/site.css"
FileUtils.cp site_css, RAILS_ROOT + "/public/stylesheets/site.css" if File.exists? site_css
