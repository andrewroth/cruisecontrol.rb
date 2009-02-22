require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class PostBuildActionTest < Test::Unit::TestCase
  
  def test_should_not_perform_post_build_action_when_build_not_successful
    test_post_build_action = PostBuildAction.new
    test_post_build_action.expects(:execute).never
    stubbed_unsuccessful_build = stub(:successful? => false)
    test_post_build_action.build_finished(stubbed_unsuccessful_build)    
  end
  
  def test_should_perform_post_build_action_using_clean_environment_when_build_successful
    test_post_build_action = PostBuildAction.new
    mock_build = mock
    mock_build.expects(:in_clean_environment_on_local_copy)
    mock_build.expects(:successful? => true)
    test_post_build_action.build_finished(mock_build)    
  end
  
#  def test_should_perform_rake_task_specified_by_on_successful_build
#    test_post_build_action = PostBuildAction.new
#    test_post_build_action.on_successful_build = "ls"
#    test_post_build_action.expects(:execute).with() do |command, options|
#      command == 'ls'
#    end
#    mock_build = mock
#    mock_build.expects(:in_clean_environment_on_local_copy)
#    mock_build.expects(:successful? => true)
#    test_post_build_action.build_finished(mock_build)    
#  end
    
end