class FunctionSubSystemsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index, :new, :create]
  auto_actions_for :sub_system, [:new,:create]
  auto_actions_for :function, [:new,:create]

end
