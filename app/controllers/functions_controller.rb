class FunctionsController < ApplicationController

  hobo_model_controller

  auto_actions :all

  autocomplete
  
  def index
    @functions=Function.search(params[:search], :name).order_by(parse_sort_param(:name, :function_type)).paginate(:page => params[:page])
    if (params[:function_type]) then
      if (params[:function_type]!="") then
        @functions = @functions.function_type_is(params[:function_type])
      end
    end
    hobo_index
  end

end
