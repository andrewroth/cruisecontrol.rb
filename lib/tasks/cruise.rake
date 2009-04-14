desc 'Continuous build target'
task :cruise => ['geminstaller'] do
  # Add local user gem path, in case rcov was installed with non-root access
  
  #system "geminstaller"
  
  ENV['PATH'] = "#{ENV['PATH']}:#{File.join(Gem.user_dir, 'bin')}"
  software = "CruiseControl.rb"
  puts
  puts "[#{software}] Build environment:"
  puts "[#{software}]   #{`cat /etc/issue`}"
  puts "[#{software}]   #{`uname -a`}"
  puts "[#{software}]   #{`ruby -v`}"
  `gem env`.each_line {|line| print "[#{software}]   #{line}"}
  puts "[#{software}]   Local gems:"
  `gem list`.each_line {|line| print "[#{software}]     #{line}"}
  puts   

  out = ENV['CC_BUILD_ARTIFACTS']
  mkdir_p out unless File.directory? out if out

  ENV['SHOW_ONLY'] = 'models,lib,helpers'
  Rake::Task["test:units:rcov"].invoke
  mv 'coverage/units', "#{out}/unit test coverage" if out
  
  ENV['SHOW_ONLY'] = 'controllers'
  Rake::Task["test:functionals:rcov"].invoke
  mv 'coverage/functionals', "#{out}/functional test coverage" if out
  
  Rake::Task["test:integration"].invoke
  #mv 'public/images/charts', "#{out}/charts" if out
end
