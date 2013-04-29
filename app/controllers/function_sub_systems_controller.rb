class FunctionSubSystemsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index, :new, :create]
  auto_actions_for :sub_system, [:new,:create]
  auto_actions_for :function, [:new,:create]

  def new_for_sub_system
    hobo_new_for :sub_system do
      @this.project_temp=Project.find_by_id(1)
    end
  end

  def new_for_function
    hobo_new_for :function do
      @this.project_temp=Project.find_by_id(1)
    end
  end

end
