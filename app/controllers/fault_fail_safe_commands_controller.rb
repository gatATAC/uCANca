class FaultFailSafeCommandsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index, :new, :create]
  auto_actions_for :fault, [:new,:create]
  auto_actions_for :fail_safe_command, [:new,:create]

  def new_for_sub_system
    hobo_new_for :fault do
      @this.project_temp=Project.find_by_id(1)
    end
  end

  def new_for_function
    hobo_new_for :fail_safe_command do
      @this.project_temp=Project.find_by_id(1)
    end
  end

end
