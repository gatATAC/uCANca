class SubSystemFlowsController < ApplicationController

  hobo_model_controller

  auto_actions :all
  auto_actions_for :connector, [:create]

end
