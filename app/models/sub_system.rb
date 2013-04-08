class SubSystem < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    timestamps
  end
  attr_accessible :name, :parent, :root, :parent_id, :root_id


  belongs_to :parent, :foreign_key => :parent_id, :class_name => 'SubSystem'
  has_many :children, :foreign_key => :parent_id, :class_name => 'SubSystem', :order => :position
  belongs_to :root, :class_name => 'SubSystem'

  has_many :edges_as_source, :class_name => 'NodeEdge', :foreign_key => 'source_id', :dependent => :destroy, :order => :position
  has_many :edges_as_destination, :class_name => 'NodeEdge', :foreign_key => 'destination_id'
  has_many :sources, :through => :edges_as_destination , :accessible => true
  has_many :destinations, :through => :edges_as_source ,  :order => 'node_edges.position',:accessible => true
  
  has_many :sub_system_flows
  has_many :flows, :through => :sub_system_flows

  has_many :connectors, :order => :position

  children :connectors, :sub_system_flows, :children

  acts_as_list :scope => :parent, :psition => :position

  def full_name
    ret=name
    p=self
    while (p.parent) do
      ret=p.parent.name+"_"+ret
      p=p.parent
    end
    return ret
  end

  def self.roots
    ret = []
    self.find(:all).each { |n|
      if not n.has_parents?
        ret << n
      end
    }
    return ret
  end

  def pretree
    ret = []
    ret += sources
    sources.each { |s|
      ret += s.pretree
    }
    return ret
  end

  def subtree
    ret = []
    ret += destinations
    destinations.each { |s|
      ret += s.subtree
    }
    return ret
  end

	def has_parents?
    return sources.size > 0
  end

	def has_children?
	  return destinations.size > 0
	end



  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end
