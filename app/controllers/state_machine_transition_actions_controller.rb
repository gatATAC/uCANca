class StateMachineTransitionActionsController < ApplicationController

  hobo_model_controller

  auto_actions :write_only
  auto_actions_for :state_machine_transition, [:create]

end
