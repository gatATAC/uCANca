class StateMachineTransitionsController < ApplicationController

  hobo_model_controller

  auto_actions :all #:write_only
  auto_actions_for :state_machine_state, [:create]

end
