class StateMachinesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:new, :create]
  auto_actions_for :function_sub_system, [:new, :create]
  auto_actions_for :super_state, [:new, :create]

  def show
    @state_machine=find_instance
    respond_to do |format|
      format.gv
      format.html {
        hobo_show
      }
    end
  end

end
