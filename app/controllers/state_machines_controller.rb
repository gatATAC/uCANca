class StateMachinesController < ApplicationController

  hobo_model_controller

  auto_actions :all
  auto_actions_for :function_sub_system, [:new, :create]
  auto_actions_for :super_state, [:new, :create]

end
