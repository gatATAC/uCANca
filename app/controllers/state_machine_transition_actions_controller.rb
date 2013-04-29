class StateMachineTransitionActionsController < ApplicationController

  hobo_model_controller

  auto_actions :write_only
  auto_actions_for :transition, [:create]

end
