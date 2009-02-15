class ProjectsController < ApplicationController
  
  verify :params => "id", :only => [:show, :build, :code],
         :render => { :text => "Project not specified",
                      :status => 404 }
  verify :params => "path", :only => [:code],
         :render => { :text => "Path not specified",
                      :status => 404 }
  def index
    @projects = Projects.load_all
    
    respond_to do |format|
      format.html
      format.js { render :action => 'index' }
      format.rss { render :action => 'index', :layout => false }
      format.cctray { render :action => 'index', :layout => false }
    end
  end

  def show
    @project = Projects.find(params[:id])
    render :text => "Project #{params[:id].inspect} not found", :status => 404 and return unless @project

    respond_to do |format|
      format.html { redirect_to :controller => "builds", :action => "show", :project => @project }
      format.rss { render :action => 'show', :layout => false }
    end
  end

  def build
    render :text => 'Build requests are not allowed', :status => 403 and return if Configuration.disable_build_now

    @project = Projects.find(params[:id])
    render :text => "Project #{params[:id].inspect} not found", :status => 404 and return unless @project

    @project.request_build rescue nil
    @projects = Projects.load_all

    render :action => 'index', :format => :js
  end
  
  def code
    @project = Projects.find(params[:id])
    render :text => "Project #{params[:id].inspect} not found", :status => 404 and return unless @project 

    path = File.join(@project.path, 'work', params[:path])
    @line = params[:line].to_i if params[:line]
    
    if File.directory?(path)
      render :text => 'Viewing of source directories is not supported yet', :status => 500 
    elsif File.file?(path)
      @content = File.read(path)
    else
      render_not_found
    end
  end
  
  def statistics
    @project = Projects.find(params[:id])
    name = @project.name
    render :layout => true,
           :inline => %(
              <embed src="/images/charts/#{name}.svg" 
              type='image/svg+xml' width='100%' height='400'
              style='background: url(/images/big_top_gradient.png);' />
      )
  end


end