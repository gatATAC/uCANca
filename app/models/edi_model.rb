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

  validates :project, :presence => :true
  
  children :edi_processes
  
  before_save :parse_file
  
  @root_node = true
  
  def parse_file
    tempfile = xdi.queued_for_write[:original]
    doc = Nokogiri::XML(tempfile)
    parse_xml(doc)
  end
  
  def parse_xdi
    content=File.open(xdi.path).read
    doc = Nokogiri::XML(content)
    parse_xml(doc)
  end
  
  def parse_xml(doc)
    @root_node = true
    doc.root.elements.each do |node|
      parse_node(node,nil)
    end
  end
  
  def parse_node(node,parent)
    
    if @root_node == true then
      print "Root node: \n"
    end
    if node.node_name.eql? 'Process'
      parse_process(node,parent)
    else
      if node.node_name.eql? 'MemElement'
        parse_memelement(node,parent)
      else
        if node.node_name.eql? 'DataFlow'
          parse_dataflow(node,parent)
        else
          # print "Parsing node ..."+node.attr("Label").to_s+"\n"    
        end
      end
    end
  end

  def load_ss_from_edi_node(ss,node,parent)
    ss.name=node.attr("Label").to_s
    print ("ss name ")+ss.name+"\n"
    ss.abbrev=node.attr("Label").to_s
    print ("ss abbrev ")+ss.abbrev+"\n"
    ss.project=self.project
    print ("ss abbrev ")+ss.project.name+"\n"
    
    ss.parent=parent
    if (parent!=nil) then
      ss.root=parent.root
    end
    ss.layer = Layer.find(:first) 
    print ("ss layer ")+ss.layer.name+"\n"
    ss.sub_system_type=SubSystemType.find(:first)
    print ("ss type ")+ss.sub_system_type.name+"\n"
    ss.save
  end
  
  def load_fl_from_edi_node(fl,node,parent)
    fl.name=node.attr("Label").to_s
    print ("fl name ")+fl.name+"\n"
    fl.project=self.project
    print ("fl abbrev ")+fl.project.name+"\n"
    
    fl.flow_type=FlowType.find(:first)
    print ("fl type ")+fl.flow_type.name+"\n"
    fl.save
  end
  
  def parse_process(node,parent)
    print "Process: "+node.attr("Label").to_s+"\n"
    if (@root_node == true) then
      print "Is the root node\n"
    end
    ss=self.project.sub_systems.find_by_name(node.attr("Label").to_s)
    if (ss!=nil) then
      print "Node identified "+node.attr("Label").to_s+"\n"
      load_ss_from_edi_node(ss,node,parent)
    else
      print "Node not identified "+node.attr("Label").to_s+"\n"
      ss=SubSystem.new
      load_ss_from_edi_node(ss,node,parent)
    end
    if (@root_node == true) then
      @root_node=false
      ss.root=ss
      project.sub_systems << ss
    end
    node.elements.each do |child|
      parse_node(child,ss)
    end
  end  
  
  def parse_memelement(node,parent)
    print "MemElement: "+node.attr("Label").to_s+"\n"
    fl=project.flows.find_by_name(node.attr("Label").to_s)
    if (fl!=nil) then
      print "Flow identified "+node.attr("Label").to_s+"\n"
      load_fl_from_edi_node(fl,node,parent)
    else
      print "Flow not identified "+node.attr("Label").to_s+"\n"
      fl=self.project.flows.new
      load_fl_from_edi_node(fl,node,parent)
    end
#    node.elements.each do |child|
#      print "Child MemElement \n"
#      parse_node(child,nil)
#    end
  end  

  def parse_dataflow(node,parent)
    fl=project.flows.find_by_name(node.attr("Label").to_s)
    if (fl!=nil) then
      print "Flow identified "+node.attr("Label").to_s+"\n"
      load_fl_from_edi_node(fl,node,parent)
    else
      print "Flow not identified "+node.attr("Label").to_s+"\n"
      fl=self.project.flows.new
      load_fl_from_edi_node(fl,node,parent)
    end
#    print "DataFlow: "+node.attr("Label").to_s+"\n"
#    node.elements.each do |child|
#      parse_node(child,nil)
#    end
  end  
  
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
      p.DefAttrb("Name" => "Timer Size", "ObjType" => "Process", "Default" => "1", :Type => "enum", "ValRange"=>"(uint8_t,0);(uint16_t,1);(uint32_t,2);")
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
