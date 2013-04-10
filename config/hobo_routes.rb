# This is an auto-generated file: don't edit!
# You can add your own routes in the config/routes.rb file
# which will override the routes in this file.

Blocks::Application.routes.draw do


  # Resource routes for controller functions
  resources :functions


  # Resource routes for controller sub_systems
  resources :sub_systems do
    collection do
      post 'reorder'
    end
  end

  # Owner routes for controller sub_systems
  resources :sub_systems, :as => :parent, :only => [] do
    resources :children, :only => [] do
      get 'new', :on => :new, :action => 'new_for_parent'
      collection do
        post 'create', :action => 'create_for_parent'
      end
    end
  end


  # Resource routes for controller function_types
  resources :function_types


  # Resource routes for controller users
  resources :users, :only => [:edit, :show, :create, :update, :destroy] do
    collection do
      post 'signup', :action => 'do_signup'
      get 'signup'
    end
    member do
      get 'account'
      put 'activate', :action => 'do_activate'
      get 'activate'
      put 'reset_password', :action => 'do_reset_password'
      get 'reset_password'
    end
  end

  # User routes for controller users
  match 'login(.:format)' => 'users#login', :as => 'user_login'
  get 'logout(.:format)' => 'users#logout', :as => 'user_logout'
  match 'forgot_password(.:format)' => 'users#forgot_password', :as => 'user_forgot_password'


  # Resource routes for controller flow_types
  resources :flow_types


  # Resource routes for controller flows
  resources :flows do
    collection do
      get 'complete_name'
    end
  end


  # Resource routes for controller function_sub_systems
  resources :function_sub_systems, :only => [:create, :update, :destroy]

  # Owner routes for controller function_sub_systems
  resources :functions, :as => :function, :only => [] do
    resources :function_sub_systems, :only => [] do
      collection do
        post 'create', :action => 'create_for_function'
      end
    end
  end


  # Resource routes for controller sub_system_flows
  resources :sub_system_flows, :only => [:create, :update, :destroy] do
    collection do
      post 'reorder'
    end
  end

  # Owner routes for controller sub_system_flows
  resources :connectors, :as => :connector, :only => [] do
    resources :sub_system_flows, :only => [] do
      collection do
        post 'create', :action => 'create_for_connector'
      end
    end
  end


  # Resource routes for controller node_edges
  resources :node_edges, :only => [:show]


  # Resource routes for controller connectors
  resources :connectors, :only => [:new, :edit, :show, :create, :update, :destroy] do
    collection do
      post 'reorder'
    end
    member do
      post 'copy_connector_flows'
      post 'copy_flow'
      post 'copy_all_subsystem_flows'
    end
  end

  # Owner routes for controller connectors
  resources :sub_systems, :as => :sub_system, :only => [] do
    resources :connectors, :only => [] do
      get 'new', :on => :new, :action => 'new_for_sub_system'
      collection do
        post 'create', :action => 'create_for_sub_system'
      end
    end
  end

end
