class ApplicationController < ActionController::Base
  protect_from_forgery

    helper DyiRails::DyiHelper # add this expression
    
end
