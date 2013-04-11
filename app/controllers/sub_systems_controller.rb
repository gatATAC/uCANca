class SubSystemsController < ApplicationController

  hobo_model_controller

  auto_actions :all
  auto_actions_for :parent, [:new,:create]

  def new
    hobo_new do
      if (params[:super_system]) then
        ss = SubSystem.find(params[:super_system])
        @this.parent=ss
        if (@this.parent.root) then
          @this.root=@this.parent.root
        else
          @this.root=@this.parent
        end
      end
      hobo_ajax_response if request.xhr?
    end
  end

  def show
    respond_to do |format|
      format.svg {
        render :inline => find_instance.to_svg
      }
      format.html {
        hobo_show
      }
    end
  end


end
