class FlowsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:new, :create]
  auto_actions_for :project, [:new, :create]

  autocomplete

  show_action :gen_code

  def gen_code
    @flow=find_instance
    respond_to do |format|
      format.c
      format.h
      format.xcos
      format.cdp
    end
  end

=begin
  def index
    respond_to do |format|
      format.c {
        render :inline => Flow.to_c
      }
      format.h {
        render :inline => Flow.to_h
      }
      format.html {
        @flows=Flow.search(params[:search], :name).order_by(parse_sort_param(:name, :flow_type)).paginate(:page => params[:page])
        if (params[:flow_type]) then
          if (params[:flow_type]!="") then
            @flows = @flows.flow_type_is(params[:flow_type])
          end
        end
        hobo_index
      }
    end
  end
=end
end
