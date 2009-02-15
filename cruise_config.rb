# this is the file that cruise control uses to configure its own cruise build at 
# http://cruisecontrolrb.thoughtworks.com/
#   simple, ain't it

Project.configure do |project|
  #project.email_notifier.emails = ["cruisecontrolrb-developers@rubyforge.org"]
  project.email_notifier.emails = ["admin@dconr.org"]
  
  # Set filters for the statiscian plugin
  project.statistician.test_filter = ["Unit tests", 
                                      "Functional tests",
                                      "Integration tests"]    
  project.statistician.code_filter = ["Libraries",
                                      "Helpers",
                                      "Controllers", "Models"]
end
