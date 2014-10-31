class ReqDocsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:new, :create]
  auto_actions_for :project, [:new,:create]

  auto_actions :all
end
