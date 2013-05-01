class StMachSysMapsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:new, :create]
  auto_actions_for :sub_system, [:new, :create]
  auto_actions_for :state_machine, [:new, :create]

end
