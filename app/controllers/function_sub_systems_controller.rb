class FunctionSubSystemsController < ApplicationController

  hobo_model_controller

  auto_actions :write_only,:edit
  auto_actions_for :function, [:create]
  auto_actions_for :sub_system, [:create]

end
