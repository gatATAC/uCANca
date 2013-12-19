class ProjectsController < ApplicationController

  hobo_model_controller

  auto_actions :all

  auto_actions_for :owner, [:new, :create]

  show_action :gen_code

  def update
    hobo_update do
      respond_to do |format|
        format.js { hobo_ajax_response }
        format.html { redirect_to @project }
      end
    end
  end  
  
  def new
    hobo_new do
      @this.owner=current_user
    end
  end

  def gen_code
    @project=find_instance
    respond_to do |format|
      format.c
      format.h
      format.xcos
      format.cdp
      format.iox
      format.iocsv
      format.ioxls
    end
  end

  def show
    @project=find_instance
    respond_to do |format|
      format.html {
        @flows=find_instance.flows.search(params[:search], :name).order_by(parse_sort_param(:name, :flow_type)).paginate(:page => params[:page])
        if (params[:flow_type]) then
          if (params[:flow_type]!="") then
            @flows = @flows.flow_type_is(params[:flow_type])
          end
        end
        @sub_systems=find_instance.sub_systems
=begin
    @functions=Function.search(params[:search_func], :name).order_by(parse_sort_param(:name, :function_type)).paginate(:page => params[:page])
    if (params[:function_type]) then
      if (params[:function_type]!="") then
        @functions = @functions.function_type_is(params[:function_type])
      end
    end
=end
        hobo_show do
          if params[:style]
            send_file @project.logo.path(params[:style])
          else
            render
          end
        end
      }
    end
  end
end
