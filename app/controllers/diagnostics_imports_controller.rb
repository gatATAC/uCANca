class DiagnosticsImportsController < ApplicationController
  def new
    @diagnostics_import = DiagnosticsImport.new(:project_id => @project_id)
  end

  def create
    @diagnostics_import = DiagnosticsImport.new(params[:diagnostics_import])
    @diagnostics_import.project=Project.find(@diagnostics_import.project_id)
    if @diagnostics_import.save
      redirect_to root_url, notice: "Imported project flows successfully."
    else
      render :new
    end
  end
end
