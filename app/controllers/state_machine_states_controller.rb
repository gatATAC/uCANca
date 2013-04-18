class StateMachineStatesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index, :new, :create]
  auto_actions_for :state_machine, [:new, :create]

end
