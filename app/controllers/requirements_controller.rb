class RequirementsController < ApplicationController
  hobo_model_controller

  auto_actions :all, :except => [:new, :create]
  auto_actions_for :req_doc, [:new,:create]

end
