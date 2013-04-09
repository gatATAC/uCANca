class ConnectorsController < ApplicationController

  hobo_model_controller

  auto_actions :all,:except => :index
  auto_actions_for :sub_system, [:new,:create]

  web_method :copy_flows do
    @connector.copy_flows Connector.find_by_id(params['connector'])
    redirect_to this
  end
  
  web_method :copy_all_subsystem_flows do
    @connector.copy_all_subsystem_flows SubSystem.find_by_id(params['sub_system'])
    redirect_to this
  end

  def show
    respond_to do |format|
      format.svg {
        render :inline => find_instance.to_svg
      }
      format.html {
        hobo_show do
          @connector = find_instance
          @sub_system = @connector.sub_system
          @connectors = @sub_system.connectors
        end
      }
    end
  end

end
