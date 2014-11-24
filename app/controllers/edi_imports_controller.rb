class EdiImportsController < ApplicationController

  def new
    @edi_import = EdiImport.new(:edi_id => @edi_id)
  end

  def create
    @edi_import = EdiImport.new(params[:req_import])
    @edi_import.edi_model=EdiModel.find(@edi_import.edi_model_id)
    if @edi_import.save
      redirect_to root_url, notice: "Edi model successfully imported."
    else
      render :new
    end
  end
  
end
