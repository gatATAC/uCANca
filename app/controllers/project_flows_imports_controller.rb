class ProjectFlowsImportsController < ApplicationController
  def new
    @project_flows_import = ProjectFlowsImport.new(:project_id => @project_id)
  end

  def create
    @project_flows_import = ProjectFlowsImport.new(params[:project_flows_import])
    @project_flows_import.project=Project.find(@project_flows_import.project_id)
    if @project_flows_import.save
      redirect_to root_url, notice: "Imported project flows successfully."
    else
      render :new
    end
  end
end
