class ConnectorsController < ApplicationController

  hobo_model_controller

  auto_actions :all,:except => :index
  auto_actions_for :sub_system, [:new,:create]

end
