class FaultRecurrenceTimesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:new, :create]
  auto_actions_for :project, [:new,:create]

end
