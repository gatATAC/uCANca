class EdiProcess < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    ident       :integer
    label       :string
    pos_x       :integer
    pos_y       :integer
    size_x      :integer
    size_y      :integer
    master      :boolean
    description :text
    timestamps
  end
  attr_accessible :ident, :label, :pos_x, :pos_y, :size_x, :size_y, :color, :master, :description

  belongs_to :edi_model, :creator => :true, :inverse_of => :edi_processes
  belongs_to :sub_system
  
  has_many :edi_flows, :dependent => :destroy, :inverse_of => :edi_process
  
  children :edi_flows
  
  def self.create_from_scratch(s,conts)
    p=EdiProcess.create :ident => s.id, :label=>s.abbrev, :pos_x=>((conts+1)*(EdiProcess.block_width*3)), :pos_y=>EdiProcess.block_height * 2, \
      :size_x=>EdiProcess.block_width, :size_y=>EdiProcess.block_height, :description => s.name, :master=>:false
    p.sub_system=s
    return p
  end
  
  def children
    ret = []
    conts=0
    self.sub_system.children.each {|ss|
      ep=EdiProcess.find_by_sub_system_id(ss.id)
      if ep==nil then
        # Let's create the missing ediprocesses from scratch
        ep=EdiProcess.create_from_scratch(ss,conts)  
        self.edi_model.edi_processes << ep
      end
      ret << ep
      conts +=1
    }
    return ret
  end
    
  def self.cplx_block_color
    13688896
  end
  
  def self.sub_system_id_offset
    10000
  end
  
  def self.sub_system_flow_id_offset
    20000
  end  
  
  def self.sub_system_flow_id_inner_offset
    30000
  end
  
  def self.sw_hl_block_color
    16443110
  end
  
  def self.hw_block_color
    12423010
  end
  
  def self.link_color
    12632256
  end
  
  def self.data_flow_color(t)
    if t.abbrev=="sw" then
      16775880
    else
      self.link_color
    end
  end
  
  def self.mem_element_color(t)
    if t.abbrev=="sw" then
      8388736
    else
      self.link_color
    end
  end
  
  def self.block_width
    140
  end

  def self.block_height
    90
  end
  
  def self.link_height
    25
  end
  
  def self.mem_element_height
    60
  end
  
  def self.block_color(ss)
    if (ss.sub_system_type.abbrev=="hw") then
      hw_block_color
    else
      if (ss.sub_system_type.abbrev=="sw") then
        sw_hl_block_color
      else
        if (ss.sub_system_type.abbrev=="cplx") then
          cplx_block_color
        else
          sw_hl_block_color
        end
        
      end
    end
  end
  
  def output_edi_flows
    ret=[]
    conts=0
    s=self.sub_system
    s.output_flows.each{|ofl|
      oefl=self.edi_flows.find_by_flow_id(ofl)
      if oefl==nil then
        oefl=EdiFlow.create_from_scratch(ofl,conts)
      end
      conts+=1
    }    
    return ret
  end
  
  def input_edi_flows
    ret=[]
    s=self.sub_system
    s.input_flows.each{|ofl|
-      oefl=self.edi_flows.find_by_flow_id(ofl)
      if oefl==nil then
        oefl=EdiFlow.create_from_scratch(ofl)
      end
    }    
    return ret
  end
  
  def name
    self.sub_system.name
  end
  
  def to_edi_xml(xml,c,flows_father,flows_siblings)

    flows_block=[]
    input_vars_done=[]
    output_vars_done=[]
    bidir_vars_done=[]
    cont=0
    
    s=self.sub_system
    s.output_flows.each{|ofl|
      
      #if exists edi_flow, use it.  If not, create it      
      currentflow=self.edi_flows.find_by_sub_system_flow_id(ofl.id)
      if (currentflow==nil) then
        currentflow=EdiFlow.create_from_scratch(ofl,c,cont)
        self.edi_flows << currentflow
      end
      
      foundfatherflow=flows_father.find{|f| f.flow_id==ofl.flow.id}
      foundsiblingflow=flows_siblings.find{|f| f.flow_id==ofl.flow.id}      
      
      if (foundsiblingflow==nil && foundfatherflow==nil) then
        xml.MemElement(
          :Id=>"#{currentflow.ident+EdiProcess.sub_system_flow_id_offset}",
          :Label=>currentflow.label, 
          :PosX=>currentflow.pos_x, :PosY=>currentflow.pos_y, 
          :SizeX=>currentflow.size_x, :SizeY=>currentflow.size_y,
          :Color=>EdiProcess.mem_element_color(self.sub_system.sub_system_type), 
          :DataType=>currentflow.data_type,
          :Prop=>"NONE"
        )
      end
      if (s.input_flows.find_by_flow_id(ofl.flow.id)!=nil) then
        bidir="Yes"
        bidir_vars_done << ofl
      else
        bidir="No"
        output_vars_done << ofl
      end
      if (foundfatherflow==nil) then
        if (foundsiblingflow==nil) then
          identflow=ofl.id+EdiProcess.sub_system_flow_id_offset
        else
          identflow=foundsiblingflow.id+EdiProcess.sub_system_flow_id_offset
        end
      else
        identflow=foundfatherflow.id+EdiProcess.sub_system_flow_id_inner_offset
      end
      if (foundfatherflow!=nil) then
        colortoset=EdiProcess.data_flow_color(self.sub_system.parent.sub_system_type)
      else
        colortoset=EdiProcess.data_flow_color(self.sub_system.sub_system_type)
      end
      xml.DataFlow(:Label=>ofl.flow.name, 
        :Color=>colortoset, 
        :PosX=>currentflow.pos_x_dataflow, :PosY=>currentflow.pos_y_dataflow, 
        :Destination=>"#{identflow}",
        :Source=>self.ident+EdiProcess.sub_system_id_offset, :OrderSource=>"0", :OrderDestination=>"0", 
        :DataType=>currentflow.data_type,
        :Prop=>"NONE", :Bidirection=>bidir )
      flows_block << ofl
      cont+=1
    }

    cont=0
    s.input_flows.each{|ifl|
      
      #if exists edi_flow, use it.  If not, create it      
      currentflow=self.edi_flows.find_by_sub_system_flow_id(ifl.id)
      if (currentflow==nil) then
        currentflow=EdiFlow.create_from_scratch(ifl,c,cont)
        self.edi_flows << currentflow
      end

      foundfatherflow=flows_father.find{|f| f.flow_id==ifl.flow.id}
      foundsiblingflow=flows_siblings.find{|f| f.flow_id==ifl.flow.id}      
      foundblockflow=flows_block.find{|f| f.flow_id==ifl.flow.id}
      foundbidirflow=bidir_vars_done.find{|f| f.flow_id==ifl.flow.id}
      if (foundblockflow==nil and foundfatherflow==nil and foundsiblingflow==nil and foundbidirflow==nil) then
        xml.MemElement(
          :Id=>"#{currentflow.ident+EdiProcess.sub_system_flow_id_offset}",
          :Label=>currentflow.label, 
          :PosX=>currentflow.pos_x, :PosY=>currentflow.pos_y, 
          :SizeX=>currentflow.size_x, :SizeY=>currentflow.size_y,
          :Color=>EdiProcess.mem_element_color(self.sub_system.sub_system_type), 
          :DataType=>currentflow.data_type,
          :Prop=>"NONE"
        )
      end
      if (foundfatherflow==nil) then
        if (foundsiblingflow==nil) then
          identflow=ifl.id+EdiProcess.sub_system_flow_id_offset
        else
          identflow=foundsiblingflow.id+EdiProcess.sub_system_flow_id_offset
        end
      else
        identflow=foundfatherflow.id+EdiProcess.sub_system_flow_id_inner_offset
      end
      if (foundfatherflow!=nil) then
        colortoset=EdiProcess.data_flow_color(self.sub_system.parent.sub_system_type)
      else
        colortoset=EdiProcess.data_flow_color(self.sub_system.sub_system_type)
      end
      if (foundbidirflow==nil) then
        xml.DataFlow(:Label=>ifl.flow.name, 
          :Color=>colortoset, 
          :PosX=>currentflow.pos_x_dataflow, :PosY=>currentflow.pos_y_dataflow, 
          :Source=>"#{identflow}",
          :Destination=>"#{self.ident+EdiProcess.sub_system_id_offset}", :OrderSource=>"0", :OrderDestination=>"0", 
          :DataType=>currentflow.data_type,
          :Prop=>"NONE", :Bidirection=>"No" 
        )
        input_vars_done << ifl
      end
      flows_block << ifl
      cont+=1
    }
    xml.Process("Id"=>s.id+EdiProcess.sub_system_id_offset, "Label" => s.abbrev, "PosX"=>self.pos_x.to_s, "PosY"=>self.pos_y.to_s,
      "SizeX" =>self.size_x.to_s, "SizeY"=>self.size_x.to_s, "Color"=> EdiProcess.block_color(s),
      "Shape"=>"Rectangle","Master"=>"No", "Order"=>"No", "Code"=>"", "Description"=>self.description){|p|
      p.Attrb("Name" => "Block Id", "Value" => s.abbrev, "Type" => "string")
      p.Attrb("Name" => "Source Arch. Module "+1.to_s, "Value" => "", "Type" => "url")
      p.Attrb("Name" => "Software Requirement "+1.to_s, "Value" => "", "Type" => "url")
      p.Attrb("Name" => "code_gen", "Value" => "0", "Type" => "enum")
      p.Attrb("Name" => "Exec. Order", "Value" => "", "Type" => "int")
      p.Attrb("Name" => "Timer Size", "Value" => "1", "Type" => "enum")
        
      colortoset=EdiProcess.mem_element_color(self.sub_system.sub_system_type)
      posy=20
      input_vars_done.each { |item|
        p.MemElement(
          :Id=>item.id+EdiProcess.sub_system_flow_id_inner_offset,
          :Label=>item.flow.name,
          :Color=>colortoset,
          :PosX=>40, :PosY=>posy, 
          :SizeX=>80, :SizeY=>58, 
          :DataType => item.flow.flow_type.name,
          :Prop =>"READ"
        )
        posy+=EdiProcess.mem_element_height
      }
      posy=20
      output_vars_done.each { |item|
        p.MemElement(
          :Id=>item.id+EdiProcess.sub_system_flow_id_inner_offset,
          :Label=>item.flow.name,
          :Color=>colortoset,
          :PosX=>80, :PosY=>posy, 
          :SizeX=>80, :SizeY=>58, 
          :DataType => item.flow.flow_type.name,
          :Prop =>"WRITE"
        )
        posy+=EdiProcess.mem_element_height
      }
      posy=20
      bidir_vars_done.each { |item|
        p.MemElement(
          :Id=>item.id+EdiProcess.sub_system_flow_id_inner_offset,
          :Label=>item.flow.name,
          :Color=>colortoset,
          :PosX=>120, :PosY=>posy, 
          :SizeX=>80, :SizeY=>58, 
          :DataType => item.flow.flow_type.name,
          :Prop =>"READWRITE"
        )
        posy+=EdiProcess.mem_element_height
      }

      contsystem=0
      flows_siblings+=flows_block
      flows_children=[]
      self.children.each{|ep|
        flows_children=ep.to_edi_xml(p,contsystem,flows_block,flows_children)
        contsystem+=1
      }
      return flows_siblings
    }
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
