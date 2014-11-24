class EdiModelsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:new, :create]
  auto_actions_for :project, [:new,:create]

  auto_actions :all
  
  
  show_action :gen_code

  def gen_code
    @edi_model=find_instance
    respond_to do |format|
      format.xdi
    end
  end

end
