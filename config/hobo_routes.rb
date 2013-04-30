# This is an auto-generated file: don't edit!
# You can add your own routes in the config/routes.rb file
# which will override the routes in this file.

Blocks::Application.routes.draw do


  # Resource routes for controller state_machine_conditions
  resources :state_machine_conditions, :only => [:edit, :show, :update, :destroy]

  # Owner routes for controller state_machine_conditions
  resources :function_sub_systems, :as => :function_sub_system, :only => [] do
    resources :state_machine_conditions, :only => [] do
      get 'new', :on => :new, :action => 'new_for_function_sub_system'
      collection do
        post 'create', :action => 'create_for_function_sub_system'
      end
    end
  end


  # Resource routes for controller functions
  resources :functions, :only => [:new, :edit, :show, :create, :update, :destroy] do
    collection do
      get 'complete_name'
    end
  end

  # Owner routes for controller functions
  resources :projects, :as => :project, :only => [] do
    resources :functions, :only => [] do
      get 'new', :on => :new, :action => 'new_for_project'
      collection do
        post 'create', :action => 'create_for_project'
      end
    end
  end


  # Resource routes for controller state_machine_states
  resources :state_machine_states, :only => [:edit, :show, :update, :destroy]

  # Owner routes for controller state_machine_states
  resources :state_machines, :as => :state_machine, :only => [] do
    resources :state_machine_states, :only => [] do
      get 'new', :on => :new, :action => 'new_for_state_machine'
      collection do
        post 'create', :action => 'create_for_state_machine'
      end
    end
  end


  # Resource routes for controller state_machine_transition_actions
  resources :state_machine_transition_actions, :only => [:create, :update, :destroy]

  # Owner routes for controller state_machine_transition_actions
  resources :state_machine_transitions, :as => :transition, :only => [] do
    resources :transition_actions, :only => [] do
      collection do
        post 'create', :action => 'create_for_transition'
      end
    end
  end


  # Resource routes for controller projects
  resources :projects, :only => [:index, :edit, :show, :update, :destroy] do
    member do
      get 'gen_code'
    end
  end

  # Owner routes for controller projects
  resources :users, :as => :owner, :only => [] do
    resources :projects, :only => [] do
      get 'new', :on => :new, :action => 'new_for_owner'
      collection do
        post 'create', :action => 'create_for_owner'
      end
    end
  end


  # Resource routes for controller function_tests
  resources :function_tests, :only => [:edit, :show, :update, :destroy] do
    collection do
      post 'reorder'
    end
  end

  # Owner routes for controller function_tests
  resources :functions, :as => :function, :only => [] do
    resources :function_tests, :only => [] do
      get 'new', :on => :new, :action => 'new_for_function'
      collection do
        post 'create', :action => 'create_for_function'
      end
    end
  end


  # Resource routes for controller sub_systems
  resources :sub_systems, :only => [:new, :edit, :show, :create, :update, :destroy] do
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

  # Owner routes for controller sub_systems
  resources :projects, :as => :project, :only => [] do
    resources :sub_systems, :only => [] do
      get 'new', :on => :new, :action => 'new_for_project'
      collection do
        post 'create', :action => 'create_for_project'
      end
    end
  end


  # Resource routes for controller function_types
  resources :function_types


  # Resource routes for controller project_memberships
  resources :project_memberships, :only => [:create, :update, :destroy]


  # Resource routes for controller state_machine_transitions
  resources :state_machine_transitions, :only => [:edit, :show, :update, :destroy]

  # Owner routes for controller state_machine_transitions
  resources :state_machine_states, :as => :state_machine_state, :only => [] do
    resources :state_machine_transitions, :only => [] do
      get 'new', :on => :new, :action => 'new_for_state_machine_state'
      collection do
        post 'create', :action => 'create_for_state_machine_state'
      end
    end
  end


  # Resource routes for controller users
  resources :users, :only => [:edit, :show, :create, :update, :destroy] do
    collection do
      get 'complete_name'
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
  resources :flows, :only => [:new, :edit, :show, :create, :update, :destroy] do
    collection do
      get 'complete_name'
    end
    member do
      get 'gen_code'
    end
  end

  # Owner routes for controller flows
  resources :projects, :as => :project, :only => [] do
    resources :flows, :only => [] do
      get 'new', :on => :new, :action => 'new_for_project'
      collection do
        post 'create', :action => 'create_for_project'
      end
    end
  end


  # Resource routes for controller function_sub_systems
  resources :function_sub_systems, :only => [:edit, :show, :update, :destroy] do
    collection do
      post 'reorder'
    end
  end

  # Owner routes for controller function_sub_systems
  resources :sub_systems, :as => :sub_system, :only => [] do
    resources :function_sub_systems, :only => [] do
      get 'new', :on => :new, :action => 'new_for_sub_system'
      collection do
        post 'create', :action => 'create_for_sub_system'
      end
    end
  end

  # Owner routes for controller function_sub_systems
  resources :functions, :as => :function, :only => [] do
    resources :function_sub_systems, :only => [] do
      get 'new', :on => :new, :action => 'new_for_function'
      collection do
        post 'create', :action => 'create_for_function'
      end
    end
  end


  # Resource routes for controller state_machine_actions
  resources :state_machine_actions, :only => [:edit, :show, :update, :destroy]

  # Owner routes for controller state_machine_actions
  resources :function_sub_systems, :as => :function_sub_system, :only => [] do
    resources :state_machine_actions, :only => [] do
      get 'new', :on => :new, :action => 'new_for_function_sub_system'
      collection do
        post 'create', :action => 'create_for_function_sub_system'
      end
    end
  end


  # Resource routes for controller sub_system_flows
  resources :sub_system_flows, :only => [:new, :edit, :show, :create, :update, :destroy] do
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


  # Resource routes for controller state_machines
  resources :state_machines, :only => [:edit, :show, :update, :destroy]

  # Owner routes for controller state_machines
  resources :function_sub_systems, :as => :function_sub_system, :only => [] do
    resources :state_machines, :only => [] do
      get 'new', :on => :new, :action => 'new_for_function_sub_system'
      collection do
        post 'create', :action => 'create_for_function_sub_system'
      end
    end
  end

  # Owner routes for controller state_machines
  resources :state_machine_states, :as => :super_state, :only => [] do
    resources :sub_machines, :only => [] do
      get 'new', :on => :new, :action => 'new_for_super_state'
      collection do
        post 'create', :action => 'create_for_super_state'
      end
    end
  end


  # Resource routes for controller node_edges
  resources :node_edges, :only => [:show]


  # Resource routes for controller layers
  resources :layers


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
