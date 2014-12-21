class EdiFlow < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    ident      :integer
    label      :string
    pos_x      :integer
    pos_y      :integer
    pos_x_inner :integer
    pos_y_inner :integer
    pos_x_dataflow      :integer
    pos_y_dataflow      :integer
    pos_x_inner_dataflow :integer
    pos_y_inner_dataflow :integer
    data_type  :string
    size_x     :integer
    size_y     :integer
    bidir      :boolean
    timestamps
  end
  attr_accessible :ident, :label, :pos_x, :pos_y, :pos_x_inner, :pos_y_inner,:pos_x_dataflow, :pos_y_dataflow, :pos_x_inner_dataflow, :pos_y_inner_dataflow, :data_type, :size_x, :size_y

  belongs_to :sub_system_flow
  belongs_to :edi_process, :creator =>:true, :inverse_of => :edi_flows

  def name
    self.sub_system_flow.flow.name
  end
    
  
  def self.create_from_scratch(ssf,c,cont)
    if  ssf.flow_direction.name=="input" then
      posx=((c+0.6)*(EdiProcess.block_width*3))
      posy=EdiProcess.block_height+(cont*EdiProcess.mem_element_height)
      posxdataflow=((c+0.8)*(EdiProcess.block_width*3))
      posydataflow=EdiProcess.block_height+(cont*EdiProcess.mem_element_height) 
    else
      posx=((c+1.4)*(EdiProcess.block_width*3))
      posy=EdiProcess.block_height+(cont*EdiProcess.mem_element_height)
      posxdataflow=((c+1.2)*(EdiProcess.block_width*3))
      posydataflow=EdiProcess.block_height+(cont*EdiProcess.mem_element_height)
    end

    p=EdiFlow.create :ident => ssf.id, :label=>ssf.flow.name, \
      :pos_x=>posx, :pos_y=>posy, \
      :pos_x_dataflow=>posxdataflow, :pos_y_dataflow=>posydataflow, \
      :pos_x_inner=>((EdiProcess.block_width*3)), :pos_y_inner=>EdiProcess.block_height+(cont*EdiProcess.mem_element_height), \
      :pos_x_inner_dataflow=>((EdiProcess.block_width*3)), :pos_y_inner_dataflow=>EdiProcess.block_height+(cont*EdiProcess.mem_element_height), \
      :size_x=>80, :size_y=>58, \
      :data_type=>ssf.flow.flow_type.name
    p.sub_system_flow=ssf
    return p  
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
