class FaultsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:new, :create]
  auto_actions_for :fault_requirement, [:new,:create]

  show_action :show_calibration
  show_action :show_calibration_extern  
  
  def show_calibration
    @item = find_instance
  end

  def show_calibration_extern
    @item = find_instance
  end

end
