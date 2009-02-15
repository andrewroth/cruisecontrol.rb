require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class StatisticanTest < Test::Unit::TestCase
  include FileSandbox
  
  def setup
    setup_sandbox

    @project = Project.new("mystats")
    @project.path = @sandbox.root
    
    @statistician = Statistician.new(@project)
    @statistician.test_filter = ["Unit tests", "Functional tests", "Integration tests"]
    @statistician.code_filter = ["Libraries", "Helpers", "Controllers", "Models"]
    
    @project.add_plugin(@statistician)
  end
  
  def teardown
    teardown_sandbox
  end
   
  def test_append_stats
    @sandbox.new :file => 'statistics.yaml', :with_contents => ''
    @statistician.append_stats(@project)
    
    #stats_file = File.open("#{RAILS_ROOT}/work/_sapublic/images/charts/mystats.svg"){|f| f.read }  
    #assert_match /mystats/, svg_file
  end
    
  def test_plot_stats
    content = File.open("#{RAILS_ROOT}/test/fixtures/statistics.yaml"){|f| f.read }
    @sandbox.new :file => 'statistics.yaml', :with_contents => content
    @statistician.plot_stats(@project)
    
    svg_file = File.open("#{RAILS_ROOT}/public/images/charts/mystats.svg"){|f| f.read }  
    assert_match /mystats/, svg_file
  end

end
