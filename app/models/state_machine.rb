class StateMachine < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    graphviz_link :string, :default => "?cht=gv:neato&amp;chl=digraph{edge[fontsize=7];fontsize=11;nodesep=1;ranksep=1;sep=3;overlap=scale;"
    graphviz_size :string, :default => "&amp;chs=500x500"
    timestamps
  end
  attr_accessible :name, :function_sub_system, :function_sub_system_id, :graphviz_link, :graphviz_size

  belongs_to :function_sub_system

  has_many :state_machine_states, :inverse_of => :state_machine
  has_many :state_machine_transitions, :through => :state_machine_states
  belongs_to :super_state, :class_name => 'StateMachineState', :inverse_of => :sub_machines, :foreign_key => :super_state_id
  has_many :sub_machines, :through => :state_machine_states, :class_name => 'StateMachine', :foreign_key => :super_state_id

  has_many :st_mach_sys_maps, :dependent => :destroy, :inverse_of => :state_machine

  children :state_machine_states, :sub_machines, :st_mach_sys_maps

  validates :function_sub_system, :presence => :true

  def to_func_name
    ret=function_sub_system.to_func_name+"_"+name.to_s
    return ret
  end

  def to_graphviz
    ret="https://chart.googleapis.com/chart"+self.graphviz_link;
    added=false
    self.state_machine_states.initial.each {|i|
      if (!added) then
        ret+="node[shape=point;width=0.2];"
        added=true
      end
      ret+="#{i.name};"
    }
    ret+="node[shape=ellipse];"
    tailp=["n","e","w","ne","se","sw","nw","s"]
    tailpcont=0
    self.state_machine_transitions.each{|t|
      ret+="#{t.state_machine_state.name}->#{t.destination_state.name}[label=&quot;[#{t.condition_name}]"
      ret+=t.action_short_names.join("(),")+"()"
      ret+="&quot;"
      if (t.destination_state==t.state_machine_state) then
        ret+=",tailport=#{tailp[tailpcont%tailp.size]},headport=#{tailp[tailpcont%tailp.size]}"
        tailpcont=tailpcont+1
      end
      ret+="];"
    }
    #ret+=";Counting->Counting[label=&quot;[equal]reset()&quot;];Counting->Counting[label=&quot;[diff]increment()&quot;];Counting->Counting[label=&quot;[expired]copy();reset()&quot;]}&amp;chs=500x500"
    return ret+"; }"+self.graphviz_size
  end

  # --- Permissions --- #

  def create_permitted?
    if (function_sub_system) then
      return function_sub_system.updatable_by?(acting_user)
    else
      true
    end
  end

  def update_permitted?
    if (function_sub_system) then
      return function_sub_system.updatable_by?(acting_user)
    else
      true
    end
  end

  def destroy_permitted?
    if (function_sub_system) then
      return function_sub_system.updatable_by?(acting_user)
    else
      true
    end
  end

  def view_permitted?(field)
    ret=false
    if (function_sub_system) then
      if (field != :graphviz_link &&
            field != :graphviz_size) then
        ret=function_sub_system.viewable_by?(acting_user)
      else
        ret=function_sub_system.updatable_by?(acting_user)
      end
    else
      ret=(field != :graphviz_link &&
          field != :graphviz_size) || acting_user.developer? || acting_user.administrator?
    end
    return ret
  end

end
