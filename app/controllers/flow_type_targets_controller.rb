class FlowTypeTargetsController < ApplicationController

  hobo_model_controller

  auto_actions :all,:except => [:index, :new, :create]
  auto_actions_for :target, [:new,:create]

  def show
    respond_to do |format|
      format.c {
        render :inline => find_instance.to_c_preview
      }
      format.html {
        hobo_show
      }
    end
  end  
  
end
