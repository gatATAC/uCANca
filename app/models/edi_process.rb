class EdiProcess < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    ident       :integer
    label       :string
    pos_x       :integer
    pos_y       :integer
    size_x      :integer
    size_y      :integer
    color       :integer
    master      :boolean
    description :text
    timestamps
  end
  attr_accessible :ident, :label, :pos_x, :pos_y, :size_x, :size_y, :color, :master, :description

  belongs_to :edi_model, :creator => :true, :inverse_of => :edi_processes
  belongs_to :sub_system
  
  has_many edi_flows, :dependent => :destroy, :inverse_of => :edi_process
  
  children :edi_flows
  
  def self.create_from_scratch(s,conts)
    p=EdiProcess.create :ident => s.id, :label=>s.abbrev, :pos_x=>((conts+1)*(EdiProcess.block_width*3)), :pos_y=>EdiProcess.block_height * 2, \
      :size_x=>EdiProcess.block_width, :size_y=>EdiProcess.block_height, :color=>EdiProcess.block_color(s),:description => s.name, :master=>:false
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
    16443110
  end
  
  def self.link_color
    12632256
  end
  
  def self.data_flow_color 
    16775880
  end
  
  def self.mem_element_color
    8388736
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
      oefl=self.edi_flows.find_by_flow_id(ofl)
      if oefl==nil then
        oefl=EdiFlow.create_from_scratch(ofl)
      end
    }    
    return ret
  end
  
  def to_edi_xml(xml,c,flows_father,flows_siblings)

    flows_block=[]
    input_links_done=[]
    output_links_done=[]
    input_vars_done=[]
    output_vars_done=[]
    bidir_vars_done=[]
    cont=0
    
    s=self.sub_system
    s.output_flows.each{|ofl|
      
      
      
      
      #determine if the flow must be treated as link or as variable
      uselink=true
      foundfatherflow=flows_father.find{|f| f.flow_id==ofl.flow.id}
      foundsiblingflow=flows_siblings.find{|f| f.flow_id==ofl.flow.id}      
      if (foundfatherflow==nil and s.sub_system_type.abbrev=="sw") then
        uselink=false;
      end
      
      if (uselink) then
        xml.Link(:Label=>ofl.flow.name, :Color=>EdiProcess.link_color, :PosX=>((c+1.4)*(EdiProcess.block_width*3)).to_s, :PosY=>EdiProcess.block_height+(cont*EdiProcess.link_height), :Destination=>"-1", :Source=>ofl.sub_system.id+EdiProcess.sub_system_id_offset, 
          :OrderSource=>"0", :OrderDestination=>"0", :DataType=>"Hw signal", :Prop =>"NONE"){
          xml.Attrb(:Name=>"Port Type", :Value=>"I/O", :Type=>"string")
        }
        output_links_done << ofl
      else
        if (foundsiblingflow==nil) then
          xml.MemElement(
            :Id=>"#{ofl.id+EdiProcess.sub_system_flow_id_offset}",
            :Label=>ofl.flow.name, 
            :PosX=>((c+1.4)*(EdiProcess.block_width*3)).to_s, :PosY=>EdiProcess.block_height+(cont*EdiProcess.mem_element_height), 
            :SizeX=>80, :SizeY=>58,
            :Color=>EdiProcess.mem_element_color, 
            :DataType=>"#{ofl.flow.flow_type.name}",
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
            ident=ofl.id+EdiProcess.sub_system_flow_id_offset
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
      end
      flows_block << ofl
      cont+=1
    }

    cont=0
    s.input_flows.each{|ifl|
      
      uselink=true
      foundfatherflow=flows_father.find{|f| f.flow_id==ifl.flow.id}
      foundsiblingflow=flows_siblings.find{|f| f.flow_id==ifl.flow.id}      
      if (foundfatherflow==nil and s.sub_system_type.abbrev=="sw") then
        uselink=false;
      end
      
      if (uselink) then
        xml.Link(:Label=>ifl.flow.name, :Color=>EdiProcess.link_color.to_s, "PosX"=>((c+0.6)*(EdiProcess.block_width*3)).to_s, "PosY"=>EdiProcess.block_height+(cont*EdiProcess.link_height), :Source=>"-1", :Destination=>ifl.sub_system.id+EdiProcess.sub_system_id_offset, 
          :OrderSource=>"0", :OrderDestination=>"0", :DataType=>"Hw signal", :Prop =>"NONE"){
          xml.Attrb(:Name=>"Port Type", :Value=>"I/O", :Type=>"string")
        }
        input_links_done << ifl
      else
        foundblockflow=flows_block.find{|f| f.flow_id==ifl.flow.id}
        if (!foundblockflow and foundsiblingflow==nil) then
          xml.MemElement(
            :Id=>"#{ifl.id+EdiProcess.sub_system_flow_id_offset}",
            :Label=>ifl.flow.name, 
            :PosX=>((c+0.6)*(EdiProcess.block_width*3)).to_s, :PosY=>EdiProcess.block_height+(cont*EdiProcess.mem_element_height), 
            :SizeX=>80, :SizeY=>58,
            :Color=>EdiProcess.mem_element_color, 
            :DataType=>"#{ifl.flow.flow_type.name}",
            :Prop=>"NONE"
          )
        end
        if (foundfatherflow==nil) then
          if (foundsiblingflow==nil) then
            ident=ifl.id+EdiProcess.sub_system_flow_id_offset
          else
            ident=foundsiblingflow.id+EdiProcess.sub_system_flow_id_offset
          end
        else
          ident=foundfatherflow.id+EdiProcess.sub_system_flow_id_inner_offset
        end
        xml.DataFlow(:Label=>ifl.flow.name, 
          :Color=>EdiProcess.data_flow_color, 
          :PosX=>((c+0.8)*(EdiProcess.block_width*3)).to_s, :PosY=>EdiProcess.block_height+(cont*EdiProcess.mem_element_height), 
          :Source=>"#{ident}",
          :Destination=>"#{s.id+EdiProcess.sub_system_id_offset}", :OrderSource=>"0", :OrderDestination=>"0", 
          :DataType=>"#{ifl.flow.flow_type.name}",
          :Prop=>"NONE2", :Bidirection=>"No" 
        )
        input_vars_done << ifl
      end
      flows_block << ifl
      cont+=1
    }
    xml.Process("Id"=>s.id+EdiProcess.sub_system_id_offset, "Label" => s.abbrev, "PosX"=>self.pos_x.to_s, "PosY"=>self.pos_y.to_s,
      "SizeX" =>self.size_x.to_s, "SizeY"=>self.size_x.to_s, "Color"=>self.color.to_s,
      "Shape"=>"Rectangle","Master"=>"No", "Order"=>"No", "Code"=>"", "Description"=>self.description){|p|
      p.Attrb("Name" => "Block Id", "Value" => s.abbrev, "Type" => "string")
      p.Attrb("Name" => "Source Arch. Module "+1.to_s, "Value" => "", "Type" => "url")
      p.Attrb("Name" => "Software Requirement "+1.to_s, "Value" => "", "Type" => "url")
      p.Attrb("Name" => "code_gen", "Value" => "0", "Type" => "enum")
      p.Attrb("Name" => "Exec. Order", "Value" => "", "Type" => "int")
      p.Attrb("Name" => "Timer Size", "Value" => "1", "Type" => "enum")
        
      posy=20
      output_links_done.each { |item|
        p.Link(:Label=>item.flow.name, :Color=>13171450, :PosX=>520, :PosY=>posy, :Source=>"-1",:Destination=>"-1",
          :OrderSource=>"0",
          :OrderDestination=>"0",
          :DataType=>"Hw signal",
          :Prop =>"HIEROUTPUT"
        )
        posy+=EdiProcess.link_height
      }
      posy=20
      input_links_done.each { |item|
        p.Link(:Label=>item.flow.name, :Color=>13171450, :PosX=>20, :PosY=>posy, :Source=>"-1",:Destination=>"-1",
          :OrderSource=>"0",
          :OrderDestination=>"0",
          :DataType=>"Hw signal",
          :Prop =>"HIERINPUT"
        )
        posy+=EdiProcess.link_height
      }
      posy=20
      input_vars_done.each { |item|
        p.MemElement(
          :Id=>item.id+EdiProcess.sub_system_flow_id_inner_offset,
          :Label=>item.flow.name,
          :Color=>8388736,
          :PosX=>20, :PosY=>posy, 
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
          :Color=>8388736,
          :PosX=>20, :PosY=>posy, 
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
          :Color=>8388736,
          :PosX=>20, :PosY=>posy, 
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
