class StateMachineActionsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index, :new, :create]
  auto_actions_for :function_sub_system, [:new, :create]
  
end
