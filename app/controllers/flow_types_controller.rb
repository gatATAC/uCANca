class FlowTypesController < ApplicationController

  hobo_model_controller

  auto_actions :all

  def show
    respond_to do |format|
      format.c {
        render :inline => find_instance.to_c_preview
      }
      format.cpp {
        render :inline => find_instance.to_cpp_preview
      }      
      format.html {
        hobo_show
      }
    end
  end

end
