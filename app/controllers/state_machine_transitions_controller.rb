class StateMachineTransitionsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index, :new, :create]
  auto_actions_for :state_machine_state, [:new,:create]

end
