class PostBuildAction
  include CommandLine
    
  attr_reader :project
  attr_accessor :on_successful_build

  def initialize(project = nil)
    @projct = project
  end
  
  def build_finished(build)
    if build.successful? 
      build.in_clean_environment_on_local_copy do
        deployment_log = build.artifact 'deployment.log'
        execute on_successful_build, :stdout => deployment_log, :stderr => deployment_log, :escape_quotes => false
      end
    end
  end
  
end