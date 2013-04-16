class ProjectsController < ApplicationController

  hobo_model_controller

  auto_actions :show, :edit, :update, :destroy

  auto_actions_for :owner, [:new, :create]


  def show
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
        hobo_show

  end
end
