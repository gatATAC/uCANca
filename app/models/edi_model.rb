class EdiModel < ActiveRecord::Base
  require 'builder'

  hobo_model # Don't put anything above this

  fields do
    name   :string
    abbrev :string
    timestamps
  end
  attr_accessible :name, :abbrev
  
  belongs_to :project, :creator => :true, :inverse_of => :edi_models


  def to_edi_xml
    xml = ::Builder::XmlMarkup.new( :indent => 2 )
=begin
<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE EdiProject SYSTEM "EdiGra.dtd">
<EdiProject Label="903_FE1XC_S0" Description="GEELY Shifter main microcontroller (MMC) application design." Author="Ignasi Molina" Date="30/03/2012" Version="1.0" Tag="Tag">
=end
    date1 = DateTime.now
    xml.instruct! :xml, :version => "1.0", :encoding => "iso-8859-1"
    xml.declare! :DOCTYPE, :EdiProject, :SYSTEM, "EdiGra.dtd"
    xml.EdiProject(:Label => self.project.abbrev, :Description => self.project.name+" Development project",
      :Date =>date1.strftime("%d/%m/%Y"),:Author => self.project.owner.name, :Version =>"1.0", :Tag => "Tag" ) { |p|
    
      p.DefAttrb("Name" => "Author", "ObjType" => "EdiProject", "Default" => "", :Type => "string", "ValRange"=>"")
      p.DefAttrb("Name" => "Reference", "ObjType" => "EdiProject", "Default" => "", :Type => "string", "ValRange"=>"")
      p.DefAttrb("Name" => "Version", "ObjType" => "EdiProject", "Default" => "", :Type => "string", "ValRange"=>"")
      p.DefAttrb("Name" => "Date", "ObjType" => "EdiProject", "Default" => "DD/MM/YYYY", :Type => "date", "ValRange"=>"")
      p.DefAttrb("Name" => "Block Id", "ObjType" => "Process", "Default" => "", :Type => "string", "ValRange"=>"")
      p.DefAttrb("Name" => "Source Arch. Module "+1.to_s, "ObjType" => "Process", "Default" => "", :Type => "url", "ValRange"=>"")
      p.DefAttrb("Name" => "Software Requirement "+1.to_s, "ObjType" => "Process", "Default" => "", :Type => "url", "ValRange"=>"")
      p.DefAttrb("Name" => "code_gen", "ObjType" => "Process", "Default" => "0", :Type => "enum", "ValRange"=>"(FSM,0);(OsekCom,1);(FSM_Redun2,2);(FSM_Redun3,3)")
      p.DefAttrb("Name" => "Exec. Order", "ObjType" => "Process", "Default" => "", :Type => "int", "ValRange"=>"1;2;3")
      p.DefAttrb("Name" => "Timer Size", "ObjType" => "Process", "Default" => "1", :Type => "enum", "ValRange"=>"(UI_8,0);(UI_16,1);(UI_32,2);")
      p.DefAttrb("Name" => "Port Type", "ObjType" => "Link", "Default" => "I/O", :Type => "string", "ValRange"=>"")
      p.DefAttrb("Name" => "Software Requirement "+1.to_s, "ObjType" => "Transition", "Default" => "", :Type => "url", "ValRange"=>"")
      p.DefAttrb("Name" => "Priority", "ObjType" => "Transition", "Default" => "", :Type => "int", "ValRange"=>"")
      p.DefAttrb("Name" => "Software Requirement "+1.to_s, "ObjType" => "State", "Default" => "", :Type => "url", "ValRange"=>"")
      p.Attrb("Name" => "Author", "Value" => self.project.owner.name, :Type => "string")
      p.Attrb("Name" => "Reference", "Value" => self.project.abbrev, :Type => "string")
      p.Attrb("Name" => "Version", "Value" => "2.1", :Type => "string")
      p.Attrb("Name" => "Date", "Value" => date1.strftime("%d/%m/%Y"), :Type => "date")
      p.Process("Id"=>"0", "Label" => self.project.abbrev, "PosX"=>200, "PosY"=>230,"SizeX" =>140, "SizeY"=>90, "Color"=>cplx_block_color,
        "Shape"=>"Rectangle","Master"=>"No", "Order"=>"No", "Code"=>"", "Description"=>self.project.name){|p2|
        p2.Attrb("Name" => "Block Id", "Value" => self.project.abbrev, "Type" => "string")
        p2.Attrb("Name" => "Source Arch. Module "+1.to_s, "Value" => "", "Type" => "url")
        p2.Attrb("Name" => "Software Requirement "+1.to_s, "Value" => "", "Type" => "url")
        p2.Attrb("Name" => "code_gen", "Value" => "0", "Type" => "enum")
        p2.Attrb("Name" => "Exec. Order", "Value" => "", "Type" => "int")
        p2.Attrb("Name" => "Timer Size", "Value" => "1", "Type" => "enum")
        contsystem=0
        flows_root=[]
        flows_first_level=[]
        self.project.sub_systems.each{ |ss|
          if (ss.parent==nil) then
            flows_first_level=self.ss_to_edi_xml(xml,ss,contsystem,flows_root,flows_first_level)
            contsystem+=1
          end
        }
      }
    }

  end
  
  def sub_system_id_offset
    10000
  end
  
  def sub_system_flow_id_offset
    20000
  end  
  
  def sub_system_flow_id_inner_offset
    30000
  end
  
  def sw_hl_block_color
    16443110
  end
  
  def hw_block_color
    16443110
  end
  
  def cplx_block_color
    13688896
  end
  
  def link_color
    12632256
  end
  
  def data_flow_color 
    16775880
  end
  
  def mem_element_color
    8388736
  end
  
  def block_width
    140
  end

  def block_height
    90
  end
  
  def link_height
    25
  end
  
  def mem_element_height
    60
  end
  
  def block_color(ss)
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

  def ss_to_edi_xml(xml,s,c,flows_father,flows_siblings)
    #<Process Id="1" Label="Geely" PosX="285" PosY="231" SizeX="140" SizeY="90" Color="255" Shape="Rectangle" Master="No" Order="No" Code="" Description="GEELY MMC Application">          

    flows_block=[]
    input_links_done=[]
    output_links_done=[]
    input_vars_done=[]
    output_vars_done=[]
    bidir_vars_done=[]
    cont=0
    s.output_flows.each{|ofl|
      if (s.sub_system_type.abbrev!="sw") then
        xml.Link(:Label=>ofl.flow.name, :Color=>link_color, :PosX=>((c+1.4)*(block_width*3)).to_s, :PosY=>block_height+(cont*link_height), :Destination=>"-1", :Source=>ofl.sub_system.id+sub_system_id_offset, 
          :OrderSource=>"0", :OrderDestination=>"0", :DataType=>"Hw signal", :Prop =>"NONE"){
          xml.Attrb(:Name=>"Port Type", :Value=>"I/O", :Type=>"string")
        }
        output_links_done << ofl
      else
        foundfatherflow=flows_father.find{|f| f.flow_id==ofl.flow.id}
        foundsiblingflow=flows_siblings.find{|f| f.flow_id==ofl.flow.id}
        if (foundfatherflow==nil and foundsiblingflow==nil) then
          xml.MemElement(
            :Id=>"#{ofl.id+sub_system_flow_id_offset}",
            :Label=>ofl.flow.name, 
            :PosX=>((c+1.4)*(block_width*3)).to_s, :PosY=>block_height+(cont*mem_element_height), 
            :SizeX=>80, :SizeY=>58,
            :Color=>mem_element_color, 
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
            ident=ofl.id+sub_system_flow_id_offset
          else
            ident=foundsiblingflow.id+sub_system_flow_id_offset
          end
        else
          ident=foundfatherflow.id+sub_system_flow_id_inner_offset
        end
        xml.DataFlow(:Label=>ofl.flow.name, 
          :Color=>data_flow_color, 
          :PosX=>((c+1.2)*(block_width*3)).to_s, :PosY=>block_height+(cont*mem_element_height), 
          :Destination=>"#{ident}",
          :Source=>"#{s.id+sub_system_id_offset}", :OrderSource=>"0", :OrderDestination=>"0", 
          :DataType=>"#{ofl.flow.flow_type.name}",
          :Prop=>"NONE", :Bidirection=>bidir )
      end
      flows_block << ofl
      cont+=1
    }

    cont=0
    s.input_flows.each{|ifl|
      if (s.sub_system_type.abbrev!="sw") then
        xml.Link(:Label=>ifl.flow.name, :Color=>link_color.to_s, "PosX"=>((c+0.6)*(block_width*3)).to_s, "PosY"=>block_height+(cont*link_height), :Source=>"-1", :Destination=>ifl.sub_system.id+sub_system_id_offset, 
          :OrderSource=>"0", :OrderDestination=>"0", :DataType=>"Hw signal", :Prop =>"NONE"){
          xml.Attrb(:Name=>"Port Type", :Value=>"I/O", :Type=>"string")
        }
        input_links_done << ifl
      else
        foundfatherflow=flows_father.find{|f| f.flow_id==ifl.flow.id}
        foundsiblingflow=flows_siblings.find{|f| f.flow_id==ifl.flow.id}
        foundblockflow=flows_block.find{|f| f.flow_id==ifl.flow.id}
        if (foundfatherflow==nil and foundsiblingflow==nil and foundblockflow==nil) then
  				xml.MemElement(
            :Id=>"#{ifl.id+sub_system_flow_id_offset}",
            :Label=>ifl.flow.name, 
            :PosX=>((c+0.6)*(block_width*3)).to_s, :PosY=>block_height+(cont*mem_element_height), 
            :SizeX=>80, :SizeY=>58,
            :Color=>mem_element_color, 
            :DataType=>"#{ifl.flow.flow_type.name}",
            :Prop=>"NONE"
          )
        end
        if (foundfatherflow==nil) then
          if (foundsiblingflow==nil) then
            ident=ifl.id+sub_system_flow_id_offset
          else
            ident=foundsiblingflow.id+sub_system_flow_id_offset
          end
        else
          ident=foundfatherflow.id+sub_system_flow_id_inner_offset
        end
        if foundblockflow==nil then
          xml.DataFlow(:Label=>ifl.flow.name, 
            :Color=>data_flow_color, 
            :PosX=>((c+0.8)*(block_width*3)).to_s, :PosY=>block_height+(cont*mem_element_height), 
            :Source=>"#{ident}",
            :Destination=>"#{s.id+sub_system_id_offset}", :OrderSource=>"0", :OrderDestination=>"0", 
            :DataType=>"#{ifl.flow.flow_type.name}",
            :Prop=>"NONE", :Bidirection=>"No" 
          )
          input_vars_done << ifl
        end
      end
      flows_block << ifl
      cont+=1
    }
    xml.Process("Id"=>s.id+sub_system_id_offset, "Label" => s.abbrev, "PosX"=>((c+1)*(block_width*3)).to_s, "PosY"=>block_height * 2,"SizeX" =>block_width, "SizeY"=>block_height, "Color"=>block_color(s).to_s,
      "Shape"=>"Rectangle","Master"=>"No", "Order"=>"No", "Code"=>"", "Description"=>s.name){|p|
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
          posy+=link_height
        }
        posy=20
        input_links_done.each { |item|
          p.Link(:Label=>item.flow.name, :Color=>13171450, :PosX=>20, :PosY=>posy, :Source=>"-1",:Destination=>"-1",
            :OrderSource=>"0",
            :OrderDestination=>"0",
            :DataType=>"Hw signal",
            :Prop =>"HIERINPUT"
          )
          posy+=link_height
        }
        posy=20
        input_vars_done.each { |item|
          p.MemElement(
            :Id=>item.id+sub_system_flow_id_inner_offset,
            :Label=>item.flow.name,
            :Color=>8388736,
            :PosX=>20, :PosY=>posy, 
            :SizeX=>80, :SizeY=>58, 
            :DataType => item.flow.flow_type.name,
            :Prop =>"READ"
          )
          posy+=mem_element_height
        }
        posy=20
        output_vars_done.each { |item|
          p.MemElement(
            :Id=>item.id+sub_system_flow_id_inner_offset,
            :Label=>item.flow.name,
            :Color=>8388736,
            :PosX=>20, :PosY=>posy, 
            :SizeX=>80, :SizeY=>58, 
            :DataType => item.flow.flow_type.name,
            :Prop =>"WRITE"
          )
          posy+=mem_element_height
        }
        posy=20
        bidir_vars_done.each { |item|
          p.MemElement(
            :Id=>item.id+sub_system_flow_id_inner_offset,
            :Label=>item.flow.name,
            :Color=>8388736,
            :PosX=>20, :PosY=>posy, 
            :SizeX=>80, :SizeY=>58, 
            :DataType => item.flow.flow_type.name,
            :Prop =>"READWRITE"
          )
          posy+=mem_element_height
        }

      contsystem=0
      flows_siblings+=flows_block
      flows_children=[]
      s.children.each{|ss|
        flows_children=self.ss_to_edi_xml(p,ss,contsystem,flows_block,flows_children)
        contsystem+=1
      }
      return flows_siblings
    }
  end
  
  
  # --- Permissions --- #
  def create_permitted?
    if (project) then
      project.updatable_by?(acting_user)
    else
      false
    end
  end

  def update_permitted?
    project.updatable_by?(acting_user)
  end

  def destroy_permitted?
    project.destroyable_by?(acting_user)
  end

  def view_permitted?(field)
    ret=self.project.viewable_by?(acting_user)
    if (!(acting_user.developer? || acting_user.administrator?)) then
      ret=self.project.public
    end
    return ret
  end

end
