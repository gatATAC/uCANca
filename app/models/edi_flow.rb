class EdiFlow < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    ident      :integer
    label      :string
    color      :integer
    pos_x      :integer
    pos_y      :integer
    data_type  :string
    prop       :string
    attr_name  :string
    attr_value :string
    attr_type  :string
    size_x     :integer
    size_y     :integer
    edi_type   :string
    internal   :boolean
    timestamps
  end
  attr_accessible :ident, :label, :color, :pos_x, :pos_y, :data_type, :prop, :attr_name, :attr_value, :attr_type, :size_x, :size_y, :edi_type, :internal

  belongs_to :sub_system_flow
  belongs_to :edi_process, :creator =>:true, :inverse_of => :edi_flows

  
  def self.create_memelement_from_scratch(ssfl,cont, internal_value)
    p=EdiFlow.create :ident => ssfl.id+EdiProcess.sub_system_flow_id_offset, :label=>ssfl.flow.name, :color => EdiProcess.mem_element_color, 
      :pos_x=> ((c+1.4)*(EdiProcess.block_width*3)) , :pos_y => EdiProcess.block_height+(cont*EdiProcess.mem_element_height), 
      :size_x => 80, :size_y => 58,
      :data_type => ssfl.flow.flow_type.name, :prop=>"NONE", :attr_name=>"Port Type", :attr_value => "I/O", :attr_type => ":string",
      :edi_type => "MemElement", :internal => internal_value
    p.sub_system_flow=ssfl 
    return p
  end
  
  def self.create_from_scratch(ssfl, cont, flows_father,flows_siblings)
    foundfatherflow=flows_father.find{|f| f.flow_id==ssfl.id}
    foundsiblingflow=flows_siblings.find{|f| f.flow_id==ssfl.id}      
      
    if (foundsiblingflow==nil) then
      ef=EdiFlow.create_memelement_from_scratch(ssfl,cont,false)
    end
    if (s.input_flows.find_by_flow_id(ssfl.flow.id)!=nil) then
      bidir="Yes"
      bidir_vars_done << ssfl
    else
      bidir="No"
      output_vars_done << ssfl
    end
    if (foundfatherflow==nil) then
      if (foundsiblingflow==nil) then
        ident=ssfl.id+EdiProcess.sub_system_flow_id_offset
      else
        ident=foundsiblingflow.id+EdiProcess.sub_system_flow_id_offset
      end
    else
      ident=foundfatherflow.id+EdiProcess.sub_system_flow_id_inner_offset
    end
    xml.DataFlow(:Label=>ofl.flow.name, 
      :Color=>EdiProcess.data_flow_color, 
      :PosX=>((c+1.2)*(EdiProcess.block_width*3)).to_s, :PosY=>EdiProcess.block_height+(cont*EdiProcess.mem_element_height), 
      :Destination=>"#{ident}",
      :Source=>"#{s.id+EdiProcess.sub_system_id_offset}", :OrderSource=>"0", :OrderDestination=>"0", 
      :DataType=>"#{ofl.flow.flow_type.name}",
      :Prop=>"NONE", :Bidirection=>bidir )
    flows_block << ofl
    cont+=1   
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
