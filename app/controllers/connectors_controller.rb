class ConnectorsController < ApplicationController

  hobo_model_controller

  auto_actions :all,:except => :index
  auto_actions_for :sub_system, [:new,:create]

  web_method :copy_connector_flows do
    @connector.copy_connector_flows Connector.find_by_id(params['connector'])
    redirect_to this
  end

  web_method :copy_flow do
    @connector.copy_flow SubSystemFlow.find_by_id(params['sub_system_flow'])
    redirect_to this
  end

  web_method :copy_all_subsystem_flows do
    @connector.copy_all_subsystem_flows SubSystem.find_by_id(params['sub_system'])
    redirect_to this
  end

  web_method :copy_all_project_flows do
    @connector.copy_all_project_flows Project.find_by_id(params['project'])
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
