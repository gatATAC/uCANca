class ReqImportsController < ApplicationController

  def new
    @req_import = ReqImport.new(:req_doc_id => @req_doc_id)
  end

  def create
    @req_import = ReqImport.new(params[:req_import])
    @req_import.req_doc=ReqDoc.find(@req_import.req_doc_id)
    if @req_import.save
      redirect_to root_url, notice: "Requirements successfully imported."
    else
      render :new
    end
  end
  
end
