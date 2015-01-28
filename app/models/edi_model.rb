class EdiModel < ActiveRecord::Base
  require 'builder'

  hobo_model # Don't put anything above this

  fields do
    name   :string
    abbrev :string
    timestamps
  end
  has_attached_file :xdi
  #,        :whiny => false, 
  #      :path => "#{Rails.root}/files/:id.:extension"
  #validates_attachment_size :xdi, :less_than => 5.megabytes
  #validates_attachment_presence :xdi
  validates_attachment_content_type :xdi, :content_type => /^application\/(xml|octet-stream)/
  
  attr_accessible :name, :abbrev, :xdi
  
  belongs_to :project, :creator => :true, :inverse_of => :edi_models
  has_many :edi_processes, :dependent => :destroy, :inverse_of => :edi_model

  children :edi_processes
  
  
  def children
    ret=[]
    conts=0;
    project.sub_systems.each {|s|
      if s.parent==nil then
        ep=self.edi_processes.find_by_sub_system_id(s)
        if (ep==nil) then
          ep=EdiProcess.create_from_scratch(s,conts)
          self.edi_processes << ep
        end
        conts+=1
        ret << ep
      end
    }
    return ret
  end

  
  def to_edi_xml
    xml = ::Builder::XmlMarkup.new( :indent => 2 )
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
      p.Process("Id"=>"0", "Label" => self.project.abbrev, "PosX"=>200, "PosY"=>230,"SizeX" =>140, "SizeY"=>90, "Color"=>EdiProcess.cplx_block_color,
        "Shape"=>"Rectangle","Master"=>"No", "Order"=>"No", "Code"=>"", "Description"=>self.project.name){|p2|
        p2.Attrb("Name" => "Block Id", "Value" => self.project.abbrev, "Type" => "string")
        p2.Attrb("Name" => "Source Arch. Module "+1.to_s, "Value" => "", "Type" => "url")
        p2.Attrb("Name" => "Software Requirement "+1.to_s, "Value" => "", "Type" => "url")
        p2.Attrb("Name" => "code_gen", "Value" => "0", "Type" => "enum")
        p2.Attrb("Name" => "Exec. Order", "Value" => "", "Type" => "int")
        p2.Attrb("Name" => "Timer Size", "Value" => "1", "Type" => "enum")
        contprocess=0
        flows_root=[]
        flows_first_level=[]
        
        self.children.each { |e|
          if (e.sub_system.parent==nil) then
            flows_first_level=e.to_edi_xml(xml,contprocess,flows_root,flows_first_level)
            contprocess+=1
          end
        }
      }
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
