class SubSystem < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    abbrev :string
    timestamps
  end
  attr_accessible :name, :parent, :root, :parent_id, :root_id, :layer, :layer_id, :abbrev, :project, :project_id, :functions, :sub_system_type_id, :sub_system_type

  belongs_to :project, :creator => :true
  belongs_to :target
  belongs_to :layer
  belongs_to :root, :class_name => 'SubSystem'
  belongs_to :parent,  :creator => true, :foreign_key => :parent_id, :class_name => 'SubSystem'
  belongs_to :sub_system_type, :inverse_of => :sub_systems

  validates :name, :presence => :true
  validates :abbrev, :presence => :true

  validates :parent_id, confirmation: true, if: "self.parent_id!=self.id"
  
  has_many :children, :foreign_key => :parent_id, :class_name => 'SubSystem', :order => :position

  has_many :connectors, :order => :position,:dependent => :destroy

  has_many :sub_system_flows, :through => :connectors
  has_many :output_flows,:through => :connectors, :class_name => 'SubSystemFlow', :conditions => {:flow_direction_id => [2,4]},:order => :position
  has_many :input_flows,:through => :connectors, :class_name => 'SubSystemFlow', :conditions => {:flow_direction_id => [1,4]},:order => :position
  has_many :nodir_flows,:through => :connectors, :class_name => 'SubSystemFlow', :conditions => {:flow_direction_id => 3},:order => :position

  has_many :function_sub_systems, :inverse_of => :sub_system, :order => :position
  has_many :functions, :through => :function_sub_systems
  has_many :state_machines, :through => :function_sub_systems

  has_many :st_mach_sys_maps, :dependent => :destroy, :inverse_of => :sub_system

  has_many :parameters, :dependent => :destroy, :inverse_of => :sub_system  
  has_many :modes, :dependent => :destroy, :inverse_of => :sub_system  
    
    
  validates :layer, :presence => :true
  validates :project, :presence => :true

  children :connectors,:children, :function_sub_systems, :st_mach_sys_maps

  acts_as_list :scope => :parent

  def full_name
    ret=abbrev
    p=self
    while (p.parent) do
      ret=p.parent.abbrev+"_"+ret
      p=p.parent
    end
    return ret
  end

  def full_abbrev
    ret=abbrev
    p=self
    while (p.parent) do
      ret=p.parent.abbrev+"_"+ret
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
    ret += parent
    ret += parent.pretree
    return ret
  end

  def subtree
    ret = []
    ret += children
    children.each { |s|
      ret += s.subtree
    }
    return ret
  end

	def has_parents?
    return parent!=nil
  end

	def has_children?
	  return children.size > 0
	end

  def copy_connectors(s)
    s.connectors.each{ |c|
      newc=c.clone
      newc.sub_system=self
      newc.save
      newc.copy_connector_flows(c)
      newc.save
    }
  end

  def to_sim
    ret = "

function main()
{
 var canvas = document.getElementById('myCanvas');
 contexto = canvas.getContext('2d');
 ChipUserControl.init();
 
  var linea=[];
"
ret += "
  //subsystems:
  "
  linea=0;
self.children.each { |i|
  ret +="// "+i.name + "
  var "+i.name+"= new e_"+i.name+"("+(linea*100).to_s+",100);
  "    
}
ret += "
  var power=new e_power(200,50);
  var timer=new e_timer05(250,100);
  var led=new e_red_led(200,150);
  var ls7400=new e_7400(350,200);
  var led2=new e_red_led(200,200);
  var switch1=new e_switch(350,20,true);
  var switch2=new e_switch(350,100,true);  
"
ret += "

  //To add lines to connect the pins of the chips:
  
  var x=0;
  
  //Vcc:
  linea[x]=new line();
  linea[x].add_pin(power.pin[1]);
  linea[x].add_pin(switch1.pin[1]);
  x++;
  
  //Ground:
  linea[x]=new line();
  linea[x].add_pin(power.pin[2]);
  linea[x].add_pin(led.pin[2]);
  linea[x].add_pin(timer.pin[2]);
  linea[x].add_pin(ls7400.pin[7]);
  linea[x].add_pin(led2.pin[2]);
  x++;
  
  linea[x]=new line();
  linea[x].add_pin(switch1.pin[2]);
  linea[x].add_pin(timer.pin[4]);
  linea[x].add_pin(switch2.pin[1]);
  x++;
  
  linea[x]=new line();
  linea[x].add_pin(switch2.pin[2])
  linea[x].add_pin(ls7400.pin[14]);
  x++;
  
  linea[x]=new line();
  linea[x].add_pin(timer.pin[1]);
  linea[x].add_pin(led.pin[1]);
  linea[x].add_pin(ls7400.pin[1]);
  linea[x].add_pin(ls7400.pin[2]);
  x++
  
  linea[x]=new line();
  linea[x].add_pin(led2.pin[1]);
  linea[x].add_pin(ls7400.pin[3]);
  
  //Draw lines:  
  for(x=0; x<linea.length; x++) linea[x].draw();
	
  //Switch on the power:	
  power.call_engine(); 
}"
    
  end
  
  def to_svg
    yporflujo=40
    alturacaracter=10
    anchuracaracter=6
    alturaminconector=12
    maxflujos=[self.input_flows.size,self.output_flows.size,self.connectors.size*(alturaminconector/alturacaracter)].max
    yoffsetcaja=10
    yoffsetflujo=yoffsetcaja*2+alturacaracter*2
    anchuracaja=200+(self.full_name.length*anchuracaracter)
    alturacaja=(yporflujo*(maxflujos))+(alturacaracter*2)
    xoffsetcaja=200
    ycentrocaja=yoffsetflujo+(alturacaja/2)
    xcentrocaja=(anchuracaja/2)+xoffsetcaja
    alturacajaajustada=[alturacaja,yoffsetflujo+yporflujo].max
    alturapagina=alturacajaajustada+yoffsetcaja*2

    anchuraconector=anchuracaja/4
    xoffsetconectorinput=xoffsetcaja+10
    xcentroconectorinput=xoffsetconectorinput+(anchuraconector/2)
    yoffsetconector=10
    xoffsetconectoroutput=xoffsetcaja+anchuracaja-anchuraconector-10
    xcentroconectoroutput=xoffsetconectoroutput+(anchuraconector/2)
    ret="<svg
   xmlns:dc=\"http://purl.org/dc/elements/1.1/\"
   xmlns:cc=\"http://creativecommons.org/ns#\"
   xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"
   xmlns:svg=\"http://www.w3.org/2000/svg\"
   xmlns=\"http://www.w3.org/2000/svg\"
   xmlns:xlink=\"http://www.w3.org/1999/xlink\"
   version=\"1.1\"
   width=\"210mm\"
   height=\"#{alturapagina}\"
   id=\"svg2\">
  <defs
     id=\"defs4\" />
  <metadata
     id=\"metadata7\">
    <rdf:RDF>
      <cc:Work
         rdf:about=\"\">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource=\"http://purl.org/dc/dcmitype/StillImage\" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     id=\"layer1\">"
    ret+="
    <rect
       width=\"#{anchuracaja}\"
       height=\"#{alturacajaajustada}\"
       x=\"#{xoffsetcaja}\"
       y=\"#{yoffsetcaja}\"
       id=\"rect_#{self.name}\"
       style=\"fill:none;stroke:#000000;stroke-width:0.34495062;stroke-opacity:1\" />
    <a id=\"link_#{self.full_name}\" xlink:href=\"/sub_systems/#{self.id}\" xlink:title=\"#{self.full_name}\" target=\"_blank\">
      <text
       x=\"#{xcentrocaja}\"
       y=\"#{ycentrocaja}\"
       id=\"text_#{self.name}\"
       xml:space=\"preserve\"
       style=\"font-size:16px;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-align:center;line-height:100%;letter-spacing:0px;word-spacing:0px;writing-mode:lr-tb;text-anchor:middle;fill:#000000;fill-opacity:1;stroke:none;font-family:Sans;-inkscape-font-specification:Sans\"><tspan
         x=\"#{xcentrocaja}\"
         y=\"#{ycentrocaja}\"
         id=\"tspan_#{self.full_name}\">#{self.full_name}</tspan></text></a>"


    acuminput=0
    acumoutput=0
    self.connectors.each {|c|

      contador=acuminput+1;

      c.input_flows.each {|f|
        ret+="
    <rect
       width=\"#{anchuracaracter*(f.label.length+2)}\"
       height=\"1\"
       x=\"#{xoffsetcaja-(anchuracaracter*(f.label.length+2))}\"
       y=\"#{(yporflujo*(contador-1))+yoffsetflujo}\"
       id=\"line_#{f.label}\"
       style=\"fill:none;stroke:#000000;stroke-width:0.65142924;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none\" />
    <a xlink:href=\"/flows/#{f.flow.id}\" xlink:title=\"#{f.label}\" target=\"_blank\">
  <text
       x=\"#{xoffsetcaja-anchuracaracter}\"
       y=\"#{(yporflujo*(contador-1))+(yoffsetflujo-alturacaracter)}\"
       id=\"text_#{f.label}\"
       xml:space=\"preserve\"
       style=\"font-size:10px;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-align:end;line-height:100%;letter-spacing:0px;word-spacing:0px;writing-mode:lr-tb;text-anchor:end;fill:#000000;fill-opacity:1;stroke:none;font-family:Sans;-inkscape-font-specification:Sans\">
       <tspan
         x=\"#{xoffsetcaja-anchuracaracter}\"
         y=\"#{(yporflujo*(contador-1))+(yoffsetflujo-alturacaracter)}\"
         id=\"tspan_#{f.label}\">#{f.label}</tspan></text>  </a>";
        contador=contador+1
      }

      alturaconector=((contador-acuminput-1)*yporflujo)-(yoffsetconector/2)
      yoffsetconectorinput=((acuminput*yporflujo)+yoffsetcaja)+(yoffsetconector)
      ycentroconectorinput=yoffsetconectorinput+(alturaconector/2)
      if (acuminput!=contador-1) then
        ret+="
    <rect
       width=\"#{anchuraconector}\"
       height=\"#{alturaconector}\"
       x=\"#{xoffsetconectorinput}\"
       y=\"#{yoffsetconectorinput}\"
       id=\"rect_#{c.name}\"
       style=\"fill:none;stroke:#000000;stroke-width:0.34495062;stroke-opacity:1\" />
    <a id=\"link_#{c.full_name}\" xlink:href=\"/connectors/#{c.id}\" xlink:title=\"#{c.full_name}\" target=\"_blank\">
      <text
       x=\"#{xcentroconectorinput}\"
       y=\"#{ycentroconectorinput}\"
       id=\"text_#{c.name}\"
       xml:space=\"preserve\"
       style=\"font-size:16px;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-align:center;line-height:100%;letter-spacing:0px;word-spacing:0px;writing-mode:lr-tb;text-anchor:middle;fill:#000000;fill-opacity:1;stroke:none;font-family:Sans;-inkscape-font-specification:Sans\"><tspan
         x=\"#{xcentroconectorinput}\"
         y=\"#{ycentroconectorinput}\"
         id=\"tspan_#{c.name}\">#{c.name}</tspan></text></a>"
      end
      acuminput=contador-1



      contador=acumoutput+1;
      c.output_flows.each {|f|
        ret+="
    <rect
       width=\"#{anchuracaracter*(f.label.length+2)}\"
       height=\"1\"
       x=\"#{xoffsetcaja+anchuracaja}\"
       y=\"#{(yporflujo*(contador-1))+yoffsetflujo}\"
       id=\"line_#{f.label}\"
       style=\"fill:none;stroke:#000000;stroke-width:0.65142924;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none\" />
    <a xlink:href=\"/flows/#{f.flow.id}\" xlink:title=\"#{f.label}\" target=\"_blank\">
    <text
       x=\"#{xoffsetcaja+anchuracaja+anchuracaracter}\"
       y=\"#{(yporflujo*(contador-1))+(yoffsetflujo-alturacaracter)}\"
       id=\"text_#{f.label}\"
       xml:space=\"preserve\"
       style=\"font-size:10px;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-align:start;line-height:100%;letter-spacing:0px;word-spacing:0px;writing-mode:lr-tb;text-anchor:start;fill:#000000;fill-opacity:1;stroke:none;font-family:Sans;-inkscape-font-specification:Sans\">
       <tspan
         x=\"#{xoffsetcaja+anchuracaja+anchuracaracter}\"
         y=\"#{(yporflujo*(contador-1))+(yoffsetflujo-alturacaracter)}\"
         id=\"tspan_#{f.label}\">#{f.label}</tspan></text></a>";
        contador=contador+1
      }
      alturaconector=((contador-acumoutput-1)*yporflujo)-(yoffsetconector/2)
      yoffsetconectoroutput=((acumoutput*yporflujo)+yoffsetcaja)+(yoffsetconector)
      ycentroconectoroutput=yoffsetconectoroutput+(alturaconector/2)
      if (acumoutput!=contador-1) then
        ret+="
    <rect
       width=\"#{anchuraconector}\"
       height=\"#{alturaconector}\"
       x=\"#{xoffsetconectoroutput}\"
       y=\"#{yoffsetconectoroutput}\"
       id=\"rect_#{c.name}\"
       style=\"fill:none;stroke:#000000;stroke-width:0.34495062;stroke-opacity:1\" />
    <a id=\"link_#{c.full_name}\" xlink:href=\"/connectors/#{c.id}\" xlink:title=\"#{c.full_name}\" target=\"_blank\">
      <text
       x=\"#{xcentroconectoroutput}\"
       y=\"#{ycentroconectoroutput}\"
       id=\"text_#{c.name}\"
       xml:space=\"preserve\"
       style=\"font-size:16px;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-align:center;line-height:100%;letter-spacing:0px;word-spacing:0px;writing-mode:lr-tb;text-anchor:middle;fill:#000000;fill-opacity:1;stroke:none;font-family:Sans;-inkscape-font-specification:Sans\"><tspan
         x=\"#{xcentroconectoroutput}\"
         y=\"#{ycentroconectoroutput}\"
         id=\"tspan_#{c.name}\">#{c.name}</tspan></text></a>"
      end
      acumoutput=contador-1

    }
    
    ret+="
  </g>
</svg>"

  end


  def layer_visible_by?(u)
    ret=false
    if self.layer
      if self.project.owner==u then
        ret=true
      else
        self.project.project_memberships.each  {|mb|
          if (mb.user==u) then
            if (mb.maximum_layer == 0 || mb.maximum_layer>=self.layer.level) then
              ret=true
            end
          end
        }
      end
    else
      ret=false
    end
    return ret
  end




  def to_code(init,doneelems,u)
    #allowed=this.view_permitted?
    allowed=true
    if (allowed)
      ret=to_code_int(u)
      return ret,[doneelems,self.subtree]
    else
      "Not allowed operation"
    end
  end

  def to_code_embedded(u)
    return to_code(u)
  end

  def to_code_int(u)
    #allowed=s.view_permitted?
    allowed=true
    if allowed
      ret="<treeview title=\""+self.name+" Tree\">\n"
=begin
      if (self.class==Library)
        ret+=get_tree_data_xml_lb(self){|n|
          #link_to(n.name,{:controller=>'nodes', :action=>'show', :id=>n.id}, :target => "main") }
          "<a href='/nodes/"+n.id.to_s+"' target='main'>"+n.name+"</a>"
        }
      else
        if (self.class==Mode)
          ret+=get_tree_data_xml_md(self){|n|
            #link_to(n.name,{:controller=>'nodes', :action=>'show', :id=>n.id}, :target => "main") }
            "<a href='/nodes/"+n.id.to_s+"' target='main'>"+n.name+"</a>"
          }
        else
=end
      ret+=self.get_tree_data_xml_ss(u){|n|
        #link_to(n.name,{:controller=>'nodes', :action=>'show', :id=>n.id}, :target => "main") }
        "<a href='/sub_systems/"+n.id.to_s+"' target='main'>"+n.name+"</a>"
      }
=begin
        end
      end
=end
      ret+="</treeview>"
      return ret
    else
      "Not allowed operation 2"
    end
  end

  def get_tree_data_xml_ss(u)
    if self.viewable_by?(u) then
      #ret="<folder title=\""+self.name+"\" type=\"sub_systems\" code=\""+self.id.to_s+"\""+" img=\""+self.node_type.img_link+"\" action=\""+self.id.to_s+"\" >\n"
      ret="<folder title=\""+self.name+"\" type=\"sub_systems\" code=\""+self.id.to_s+"\""+" img=\"/images/nodes/subsystem.png\" action=\""+self.id.to_s+"\" >\n"

      self.state_machines.each {|sm|
        ret+=sm.get_tree_data_xml_sm()
      }

      self.connectors.each {|cn|
        ret+=cn.get_tree_data_xml_cn()
      }

      self.children.each {|n|
        ret+=n.get_tree_data_xml_ss(u)
      }
=begin
      self.modes.each {|n|
        ret+=get_tree_data_xml_md(n)
      }
=end
      ret+="</folder>\n"
    else
      ret=""
    end
    return ret
  end

  def to_xcos(child_number)
    ret=""
    if self.parent then
      ret+="<SuperBlock id=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.full_name}\" parent=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.parent.full_name}p1\" simulationFunctionType=\"DEFAULT\" style=\"SUPER_f;flip=false;mirror=false\" value=\"#{self.name}\">"
    else
      ret+="<SuperBlock id=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.full_name}\" parent=\"#{self.project.abbrev+"file:"+self.project.abbrev}p1\" simulationFunctionType=\"DEFAULT\" style=\"SUPER_f;flip=false;mirror=false\" value=\"#{self.name}\">"
    end
    ret+="<SuperBlockDiagram as=\"child\" background=\"-1\" title=\"#{self.name}\"><!--Xcos - 1.0 - scilab-branch-5.4-1363295645 - 20130315 0027-->"
    ret+="<Array as=\"context\" scilabClass=\"String[]\">"
    ret+="<add value=\"\"/>"
    ret+="</Array>"
    ret+="<mxGraphModel as=\"model\">"
    ret+="<root>"
    ret+="<mxCell id=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.full_name}p0\"/>"
    ret+="<mxCell id=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.full_name}p1\" parent=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.full_name}p0\"/>"

    ret+="                            <!-- Puertos 	 (dentro) -->"

    contop=0
    contip=0
    already_linked = []
    self.connectors.each{|c|
      c.sub_system_flows.each{|f|
        ret,contop,contip,already_linked=f.to_xcos_block(ret,contop,contip,already_linked)
      }
    }

    contchild=0
    self.children.each{|ss|
      ret+=ss.to_xcos(contchild)
      contchild+=1
    }

    ret+="</root>"
    ret+="</mxGraphModel>"
    ret+="<mxCell as=\"defaultParent\" id=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.full_name}p1\" parent=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.full_name}p0\"/>"
    ret+="</SuperBlockDiagram>"
    ret+="<Array as=\"realParameters\" scilabClass=\"ScilabMList\">"
    ret+="<ScilabString height=\"1\" width=\"5\">"
    ret+="<data column=\"0\" line=\"0\" value=\"diagram\"/>"
    ret+="<data column=\"1\" line=\"0\" value=\"props\"/>"
    ret+="<data column=\"2\" line=\"0\" value=\"objs\"/>"
    ret+="<data column=\"3\" line=\"0\" value=\"version\"/>"
    ret+="<data column=\"4\" line=\"0\" value=\"contrib\"/>"
    ret+="</ScilabString>"
    ret+="<Array scilabClass=\"ScilabTList\">"
    ret+="<ScilabString height=\"1\" width=\"11\">"
    ret+="<data column=\"0\" line=\"0\" value=\"params\"/>"
    ret+="<data column=\"1\" line=\"0\" value=\"wpar\"/>"
    ret+="<data column=\"2\" line=\"0\" value=\"title\"/>"
    ret+="<data column=\"3\" line=\"0\" value=\"tol\"/>"
    ret+="<data column=\"4\" line=\"0\" value=\"tf\"/>"
    ret+="<data column=\"5\" line=\"0\" value=\"context\"/>"
    ret+="<data column=\"6\" line=\"0\" value=\"void1\"/>"
    ret+="<data column=\"7\" line=\"0\" value=\"options\"/>"
    ret+="<data column=\"8\" line=\"0\" value=\"void2\"/>"
    ret+="<data column=\"9\" line=\"0\" value=\"void3\"/>"
    ret+="<data column=\"10\" line=\"0\" value=\"doc\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"1\" width=\"6\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"600.0\"/>"
    ret+="<data column=\"1\" line=\"0\" realPart=\"450.0\"/>"
    ret+="<data column=\"2\" line=\"0\" realPart=\"0.0\"/>"
    ret+="<data column=\"3\" line=\"0\" realPart=\"0.0\"/>"
    ret+="<data column=\"4\" line=\"0\" realPart=\"600.0\"/>"
    ret+="<data column=\"5\" line=\"0\" realPart=\"450.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"#{self.name}\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"7\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"1.0E-6\"/>"
    ret+="<data column=\"0\" line=\"1\" realPart=\"1.0E-6\"/>"
    ret+="<data column=\"0\" line=\"2\" realPart=\"1.0E-10\"/>"
    ret+="<data column=\"0\" line=\"3\" realPart=\"100001.0\"/>"
    ret+="<data column=\"0\" line=\"4\" realPart=\"0.0\"/>"
    ret+="<data column=\"0\" line=\"5\" realPart=\"1.0\"/>"
    ret+="<data column=\"0\" line=\"6\" realPart=\"0.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"100000.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<Array scilabClass=\"ScilabTList\">"
    ret+="<ScilabString height=\"1\" width=\"6\">"
    ret+="<data column=\"0\" line=\"0\" value=\"scsopt\"/>"
    ret+="<data column=\"1\" line=\"0\" value=\"3D\"/>"
    ret+="<data column=\"2\" line=\"0\" value=\"Background\"/>"
    ret+="<data column=\"3\" line=\"0\" value=\"Link\"/>"
    ret+="<data column=\"4\" line=\"0\" value=\"ID\"/>"
    ret+="<data column=\"5\" line=\"0\" value=\"Cmap\"/>"
    ret+="</ScilabString>"
    ret+="<Array scilabClass=\"ScilabList\">"
    ret+="<ScilabBoolean height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"true\"/>"
    ret+="</ScilabBoolean>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"33.0\"/>"
    ret+="</ScilabDouble>"
    ret+="</Array>"
    ret+="<ScilabDouble height=\"1\" width=\"2\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"8.0\"/>"
    ret+="<data column=\"1\" line=\"0\" realPart=\"1.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"1\" width=\"2\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"1.0\"/>"
    ret+="<data column=\"1\" line=\"0\" realPart=\"5.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<Array scilabClass=\"ScilabList\">"
    ret+="<ScilabDouble height=\"1\" width=\"2\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"5.0\"/>"
    ret+="<data column=\"1\" line=\"0\" realPart=\"1.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"1\" width=\"2\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"4.0\"/>"
    ret+="<data column=\"1\" line=\"0\" realPart=\"1.0\"/>"
    ret+="</ScilabDouble>"
    ret+="</Array>"
    ret+="<ScilabDouble height=\"1\" width=\"3\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"0.8\"/>"
    ret+="<data column=\"1\" line=\"0\" realPart=\"0.8\"/>"
    ret+="<data column=\"2\" line=\"0\" realPart=\"0.8\"/>"
    ret+="</ScilabDouble>"
    ret+="</Array>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<Array scilabClass=\"ScilabList\"/></Array>"
    ret+="<Array scilabClass=\"ScilabList\">"
    ret+="<Array scilabClass=\"ScilabMList\">"
    ret+="<ScilabString height=\"1\" width=\"5\">"
    ret+="<data column=\"0\" line=\"0\" value=\"Block\"/>"
    ret+="<data column=\"1\" line=\"0\" value=\"graphics\"/>"
    ret+="<data column=\"2\" line=\"0\" value=\"model\"/>"
    ret+="<data column=\"3\" line=\"0\" value=\"gui\"/>"
    ret+="<data column=\"4\" line=\"0\" value=\"doc\"/>"
    ret+="</ScilabString>"
    ret+="<Array scilabClass=\"ScilabMList\">"
    ret+="<ScilabString height=\"1\" width=\"19\">"
    ret+="<data column=\"0\" line=\"0\" value=\"graphics\"/>"
    ret+="<data column=\"1\" line=\"0\" value=\"orig\"/>"
    ret+="<data column=\"2\" line=\"0\" value=\"sz\"/>"
    ret+="<data column=\"3\" line=\"0\" value=\"flip\"/>"
    ret+="<data column=\"4\" line=\"0\" value=\"theta\"/>"
    ret+="<data column=\"5\" line=\"0\" value=\"exprs\"/>"
    ret+="<data column=\"6\" line=\"0\" value=\"pin\"/>"
    ret+="<data column=\"7\" line=\"0\" value=\"pout\"/>"
    ret+="<data column=\"8\" line=\"0\" value=\"pein\"/>"
    ret+="<data column=\"9\" line=\"0\" value=\"peout\"/>"
    ret+="<data column=\"10\" line=\"0\" value=\"gr_i\"/>"
    ret+="<data column=\"11\" line=\"0\" value=\"id\"/>"
    ret+="<data column=\"12\" line=\"0\" value=\"in_implicit\"/>"
    ret+="<data column=\"13\" line=\"0\" value=\"out_implicit\"/>"
    ret+="<data column=\"14\" line=\"0\" value=\"in_style\"/>"
    ret+="<data column=\"15\" line=\"0\" value=\"out_style\"/>"
    ret+="<data column=\"16\" line=\"0\" value=\"in_label\"/>"
    ret+="<data column=\"17\" line=\"0\" value=\"out_label\"/>"
    ret+="<data column=\"18\" line=\"0\" value=\"style\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"1\" width=\"2\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"20.0\"/>"
    ret+="<data column=\"1\" line=\"0\" realPart=\"-40.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"1\" width=\"2\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"20.0\"/>"
    ret+="<data column=\"1\" line=\"0\" realPart=\"20.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabBoolean height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"true\"/>"
    ret+="</ScilabBoolean>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"0.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"1\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"0.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<Array scilabClass=\"ScilabList\">"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"xstringb(orig(1),orig(2),&quot;IN_f&quot;,sz(1),sz(2));\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"8.0\"/>"
    ret+="</ScilabDouble>"
    ret+="</Array>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"input1\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"E\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"ExplicitOutputPort;align=right;verticalAlign=middle;spacing=10.0;rotation=0;flip=false;mirror=false\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"IN_f;flip=false;mirror=false\"/>"
    ret+="</ScilabString>"
    ret+="</Array>"
    ret+="<Array scilabClass=\"ScilabMList\">"
    ret+="<ScilabString height=\"1\" width=\"23\">"
    ret+="<data column=\"0\" line=\"0\" value=\"model\"/>"
    ret+="<data column=\"1\" line=\"0\" value=\"sim\"/>"
    ret+="<data column=\"2\" line=\"0\" value=\"in\"/>"
    ret+="<data column=\"3\" line=\"0\" value=\"in2\"/>"
    ret+="<data column=\"4\" line=\"0\" value=\"intyp\"/>"
    ret+="<data column=\"5\" line=\"0\" value=\"out\"/>"
    ret+="<data column=\"6\" line=\"0\" value=\"out2\"/>"
    ret+="<data column=\"7\" line=\"0\" value=\"outtyp\"/>"
    ret+="<data column=\"8\" line=\"0\" value=\"evtin\"/>"
    ret+="<data column=\"9\" line=\"0\" value=\"evtout\"/>"
    ret+="<data column=\"10\" line=\"0\" value=\"state\"/>"
    ret+="<data column=\"11\" line=\"0\" value=\"dstate\"/>"
    ret+="<data column=\"12\" line=\"0\" value=\"odstate\"/>"
    ret+="<data column=\"13\" line=\"0\" value=\"rpar\"/>"
    ret+="<data column=\"14\" line=\"0\" value=\"ipar\"/>"
    ret+="<data column=\"15\" line=\"0\" value=\"opar\"/>"
    ret+="<data column=\"16\" line=\"0\" value=\"blocktype\"/>"
    ret+="<data column=\"17\" line=\"0\" value=\"firing\"/>"
    ret+="<data column=\"18\" line=\"0\" value=\"dep_ut\"/>"
    ret+="<data column=\"19\" line=\"0\" value=\"label\"/>"
    ret+="<data column=\"20\" line=\"0\" value=\"nzcross\"/>"
    ret+="<data column=\"21\" line=\"0\" value=\"nmode\"/>"
    ret+="<data column=\"22\" line=\"0\" value=\"equations\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"input\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"-1.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"-2.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"-1.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<Array scilabClass=\"ScilabList\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"1.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<Array scilabClass=\"ScilabList\"/>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"c\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabBoolean height=\"1\" width=\"2\">"
    ret+="<data column=\"0\" line=\"0\" value=\"false\"/>"
    ret+="<data column=\"1\" line=\"0\" value=\"false\"/>"
    ret+="</ScilabBoolean>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"}input1\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"0.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"0.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<Array scilabClass=\"ScilabList\"/></Array>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"IN_f\"/>"
    ret+="</ScilabString>"
    ret+="<Array scilabClass=\"ScilabList\">"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"}input1\"/>"
    ret+="</ScilabString>"
    ret+="</Array>"
    ret+="</Array>"
    ret+="<Array scilabClass=\"ScilabMList\">"
    ret+="<ScilabString height=\"1\" width=\"5\">"
    ret+="<data column=\"0\" line=\"0\" value=\"Block\"/>"
    ret+="<data column=\"1\" line=\"0\" value=\"graphics\"/>"
    ret+="<data column=\"2\" line=\"0\" value=\"model\"/>"
    ret+="<data column=\"3\" line=\"0\" value=\"gui\"/>"
    ret+="<data column=\"4\" line=\"0\" value=\"doc\"/>"
    ret+="</ScilabString>"
    ret+="<Array scilabClass=\"ScilabMList\">"
    ret+="<ScilabString height=\"1\" width=\"19\">"
    ret+="<data column=\"0\" line=\"0\" value=\"graphics\"/>"
    ret+="<data column=\"1\" line=\"0\" value=\"orig\"/>"
    ret+="<data column=\"2\" line=\"0\" value=\"sz\"/>"
    ret+="<data column=\"3\" line=\"0\" value=\"flip\"/>"
    ret+="<data column=\"4\" line=\"0\" value=\"theta\"/>"
    ret+="<data column=\"5\" line=\"0\" value=\"exprs\"/>"
    ret+="<data column=\"6\" line=\"0\" value=\"pin\"/>"
    ret+="<data column=\"7\" line=\"0\" value=\"pout\"/>"
    ret+="<data column=\"8\" line=\"0\" value=\"pein\"/>"
    ret+="<data column=\"9\" line=\"0\" value=\"peout\"/>"
    ret+="<data column=\"10\" line=\"0\" value=\"gr_i\"/>"
    ret+="<data column=\"11\" line=\"0\" value=\"id\"/>"
    ret+="<data column=\"12\" line=\"0\" value=\"in_implicit\"/>"
    ret+="<data column=\"13\" line=\"0\" value=\"out_implicit\"/>"
    ret+="<data column=\"14\" line=\"0\" value=\"in_style\"/>"
    ret+="<data column=\"15\" line=\"0\" value=\"out_style\"/>"
    ret+="<data column=\"16\" line=\"0\" value=\"in_label\"/>"
    ret+="<data column=\"17\" line=\"0\" value=\"out_label\"/>"
    ret+="<data column=\"18\" line=\"0\" value=\"style\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"1\" width=\"2\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"220.0\"/>"
    ret+="<data column=\"1\" line=\"0\" realPart=\"-40.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"1\" width=\"2\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"20.0\"/>"
    ret+="<data column=\"1\" line=\"0\" realPart=\"20.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabBoolean height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"true\"/>"
    ret+="</ScilabBoolean>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"0.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"1\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"0.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<Array scilabClass=\"ScilabList\">"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"xstringb(orig(1),orig(2),&quot;OUT_f&quot;,sz(1),sz(2));\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"8.0\"/>"
    ret+="</ScilabDouble>"
    ret+="</Array>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"output1\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"E\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"ExplicitInputPort;align=left;verticalAlign=middle;spacing=10.0;rotation=0;flip=false;mirror=false\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"OUT_f;flip=false;mirror=false\"/>"
    ret+="</ScilabString>"
    ret+="</Array>"
    ret+="<Array scilabClass=\"ScilabMList\">"
    ret+="<ScilabString height=\"1\" width=\"23\">"
    ret+="<data column=\"0\" line=\"0\" value=\"model\"/>"
    ret+="<data column=\"1\" line=\"0\" value=\"sim\"/>"
    ret+="<data column=\"2\" line=\"0\" value=\"in\"/>"
    ret+="<data column=\"3\" line=\"0\" value=\"in2\"/>"
    ret+="<data column=\"4\" line=\"0\" value=\"intyp\"/>"
    ret+="<data column=\"5\" line=\"0\" value=\"out\"/>"
    ret+="<data column=\"6\" line=\"0\" value=\"out2\"/>"
    ret+="<data column=\"7\" line=\"0\" value=\"outtyp\"/>"
    ret+="<data column=\"8\" line=\"0\" value=\"evtin\"/>"
    ret+="<data column=\"9\" line=\"0\" value=\"evtout\"/>"
    ret+="<data column=\"10\" line=\"0\" value=\"state\"/>"
    ret+="<data column=\"11\" line=\"0\" value=\"dstate\"/>"
    ret+="<data column=\"12\" line=\"0\" value=\"odstate\"/>"
    ret+="<data column=\"13\" line=\"0\" value=\"rpar\"/>"
    ret+="<data column=\"14\" line=\"0\" value=\"ipar\"/>"
    ret+="<data column=\"15\" line=\"0\" value=\"opar\"/>"
    ret+="<data column=\"16\" line=\"0\" value=\"blocktype\"/>"
    ret+="<data column=\"17\" line=\"0\" value=\"firing\"/>"
    ret+="<data column=\"18\" line=\"0\" value=\"dep_ut\"/>"
    ret+="<data column=\"19\" line=\"0\" value=\"label\"/>"
    ret+="<data column=\"20\" line=\"0\" value=\"nzcross\"/>"
    ret+="<data column=\"21\" line=\"0\" value=\"nmode\"/>"
    ret+="<data column=\"22\" line=\"0\" value=\"equations\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"output\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"-1.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"-2.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"-1.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<Array scilabClass=\"ScilabList\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"1.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<Array scilabClass=\"ScilabList\"/>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"c\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabBoolean height=\"1\" width=\"2\">"
    ret+="<data column=\"0\" line=\"0\" value=\"false\"/>"
    ret+="<data column=\"1\" line=\"0\" value=\"false\"/>"
    ret+="</ScilabBoolean>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"}output1\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"0.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"0.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<Array scilabClass=\"ScilabList\"/></Array>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"OUT_f\"/>"
    ret+="</ScilabString>"
    ret+="<Array scilabClass=\"ScilabList\">"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"}output1\"/>"
    ret+="</ScilabString>"
    ret+="</Array>"
    ret+="</Array>"
    ret+="<Array scilabClass=\"ScilabMList\">"
    ret+="<ScilabString height=\"1\" width=\"5\">"
    ret+="<data column=\"0\" line=\"0\" value=\"Block\"/>"
    ret+="<data column=\"1\" line=\"0\" value=\"graphics\"/>"
    ret+="<data column=\"2\" line=\"0\" value=\"model\"/>"
    ret+="<data column=\"3\" line=\"0\" value=\"gui\"/>"
    ret+="<data column=\"4\" line=\"0\" value=\"doc\"/>"
    ret+="</ScilabString>"
    ret+="<Array scilabClass=\"ScilabMList\">"
    ret+="<ScilabString height=\"1\" width=\"19\">"
    ret+="<data column=\"0\" line=\"0\" value=\"graphics\"/>"
    ret+="<data column=\"1\" line=\"0\" value=\"orig\"/>"
    ret+="<data column=\"2\" line=\"0\" value=\"sz\"/>"
    ret+="<data column=\"3\" line=\"0\" value=\"flip\"/>"
    ret+="<data column=\"4\" line=\"0\" value=\"theta\"/>"
    ret+="<data column=\"5\" line=\"0\" value=\"exprs\"/>"
    ret+="<data column=\"6\" line=\"0\" value=\"pin\"/>"
    ret+="<data column=\"7\" line=\"0\" value=\"pout\"/>"
    ret+="<data column=\"8\" line=\"0\" value=\"pein\"/>"
    ret+="<data column=\"9\" line=\"0\" value=\"peout\"/>"
    ret+="<data column=\"10\" line=\"0\" value=\"gr_i\"/>"
    ret+="<data column=\"11\" line=\"0\" value=\"id\"/>"
    ret+="<data column=\"12\" line=\"0\" value=\"in_implicit\"/>"
    ret+="<data column=\"13\" line=\"0\" value=\"out_implicit\"/>"
    ret+="<data column=\"14\" line=\"0\" value=\"in_style\"/>"
    ret+="<data column=\"15\" line=\"0\" value=\"out_style\"/>"
    ret+="<data column=\"16\" line=\"0\" value=\"in_label\"/>"
    ret+="<data column=\"17\" line=\"0\" value=\"out_label\"/>"
    ret+="<data column=\"18\" line=\"0\" value=\"style\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"1\" width=\"2\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"20.0\"/>"
    ret+="<data column=\"1\" line=\"0\" realPart=\"-80.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"1\" width=\"2\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"20.0\"/>"
    ret+="<data column=\"1\" line=\"0\" realPart=\"20.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabBoolean height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"true\"/>"
    ret+="</ScilabBoolean>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"0.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"2\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"0.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<Array scilabClass=\"ScilabList\">"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"xstringb(orig(1),orig(2),&quot;IN_f&quot;,sz(1),sz(2));\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"8.0\"/>"
    ret+="</ScilabDouble>"
    ret+="</Array>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"input2\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"E\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"ExplicitOutputPort;align=right;verticalAlign=middle;spacing=10.0;rotation=0;flip=false;mirror=false\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"IN_f;flip=false;mirror=false\"/>"
    ret+="</ScilabString>"
    ret+="</Array>"
    ret+="<Array scilabClass=\"ScilabMList\">"
    ret+="<ScilabString height=\"1\" width=\"23\">"
    ret+="<data column=\"0\" line=\"0\" value=\"model\"/>"
    ret+="<data column=\"1\" line=\"0\" value=\"sim\"/>"
    ret+="<data column=\"2\" line=\"0\" value=\"in\"/>"
    ret+="<data column=\"3\" line=\"0\" value=\"in2\"/>"
    ret+="<data column=\"4\" line=\"0\" value=\"intyp\"/>"
    ret+="<data column=\"5\" line=\"0\" value=\"out\"/>"
    ret+="<data column=\"6\" line=\"0\" value=\"out2\"/>"
    ret+="<data column=\"7\" line=\"0\" value=\"outtyp\"/>"
    ret+="<data column=\"8\" line=\"0\" value=\"evtin\"/>"
    ret+="<data column=\"9\" line=\"0\" value=\"evtout\"/>"
    ret+="<data column=\"10\" line=\"0\" value=\"state\"/>"
    ret+="<data column=\"11\" line=\"0\" value=\"dstate\"/>"
    ret+="<data column=\"12\" line=\"0\" value=\"odstate\"/>"
    ret+="<data column=\"13\" line=\"0\" value=\"rpar\"/>"
    ret+="<data column=\"14\" line=\"0\" value=\"ipar\"/>"
    ret+="<data column=\"15\" line=\"0\" value=\"opar\"/>"
    ret+="<data column=\"16\" line=\"0\" value=\"blocktype\"/>"
    ret+="<data column=\"17\" line=\"0\" value=\"firing\"/>"
    ret+="<data column=\"18\" line=\"0\" value=\"dep_ut\"/>"
    ret+="<data column=\"19\" line=\"0\" value=\"label\"/>"
    ret+="<data column=\"20\" line=\"0\" value=\"nzcross\"/>"
    ret+="<data column=\"21\" line=\"0\" value=\"nmode\"/>"
    ret+="<data column=\"22\" line=\"0\" value=\"equations\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"input\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"-1.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"-2.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"-1.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<Array scilabClass=\"ScilabList\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"2.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<Array scilabClass=\"ScilabList\"/>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"c\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabBoolean height=\"1\" width=\"2\">"
    ret+="<data column=\"0\" line=\"0\" value=\"false\"/>"
    ret+="<data column=\"1\" line=\"0\" value=\"false\"/>"
    ret+="</ScilabBoolean>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"}input2\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"0.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"0.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<Array scilabClass=\"ScilabList\"/></Array>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"IN_f\"/>"
    ret+="</ScilabString>"
    ret+="<Array scilabClass=\"ScilabList\">"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"}input2\"/>"
    ret+="</ScilabString>"
    ret+="</Array>"
    ret+="</Array>"
    ret+="<Array scilabClass=\"ScilabMList\">"
    ret+="<ScilabString height=\"1\" width=\"5\">"
    ret+="<data column=\"0\" line=\"0\" value=\"Block\"/>"
    ret+="<data column=\"1\" line=\"0\" value=\"graphics\"/>"
    ret+="<data column=\"2\" line=\"0\" value=\"model\"/>"
    ret+="<data column=\"3\" line=\"0\" value=\"gui\"/>"
    ret+="<data column=\"4\" line=\"0\" value=\"doc\"/>"
    ret+="</ScilabString>"
    ret+="<Array scilabClass=\"ScilabMList\">"
    ret+="<ScilabString height=\"1\" width=\"19\">"
    ret+="<data column=\"0\" line=\"0\" value=\"graphics\"/>"
    ret+="<data column=\"1\" line=\"0\" value=\"orig\"/>"
    ret+="<data column=\"2\" line=\"0\" value=\"sz\"/>"
    ret+="<data column=\"3\" line=\"0\" value=\"flip\"/>"
    ret+="<data column=\"4\" line=\"0\" value=\"theta\"/>"
    ret+="<data column=\"5\" line=\"0\" value=\"exprs\"/>"
    ret+="<data column=\"6\" line=\"0\" value=\"pin\"/>"
    ret+="<data column=\"7\" line=\"0\" value=\"pout\"/>"
    ret+="<data column=\"8\" line=\"0\" value=\"pein\"/>"
    ret+="<data column=\"9\" line=\"0\" value=\"peout\"/>"
    ret+="<data column=\"10\" line=\"0\" value=\"gr_i\"/>"
    ret+="<data column=\"11\" line=\"0\" value=\"id\"/>"
    ret+="<data column=\"12\" line=\"0\" value=\"in_implicit\"/>"
    ret+="<data column=\"13\" line=\"0\" value=\"out_implicit\"/>"
    ret+="<data column=\"14\" line=\"0\" value=\"in_style\"/>"
    ret+="<data column=\"15\" line=\"0\" value=\"out_style\"/>"
    ret+="<data column=\"16\" line=\"0\" value=\"in_label\"/>"
    ret+="<data column=\"17\" line=\"0\" value=\"out_label\"/>"
    ret+="<data column=\"18\" line=\"0\" value=\"style\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"1\" width=\"2\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"220.0\"/>"
    ret+="<data column=\"1\" line=\"0\" realPart=\"-100.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"1\" width=\"2\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"20.0\"/>"
    ret+="<data column=\"1\" line=\"0\" realPart=\"20.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabBoolean height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"true\"/>"
    ret+="</ScilabBoolean>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"0.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"2\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"0.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<Array scilabClass=\"ScilabList\">"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"xstringb(orig(1),orig(2),&quot;OUT_f&quot;,sz(1),sz(2));\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"8.0\"/>"
    ret+="</ScilabDouble>"
    ret+="</Array>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"output2\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"E\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"ExplicitInputPort;align=left;verticalAlign=middle;spacing=10.0;rotation=0;flip=false;mirror=false\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"OUT_f;flip=false;mirror=false\"/>"
    ret+="</ScilabString>"
    ret+="</Array>"
    ret+="<Array scilabClass=\"ScilabMList\">"
    ret+="<ScilabString height=\"1\" width=\"23\">"
    ret+="<data column=\"0\" line=\"0\" value=\"model\"/>"
    ret+="<data column=\"1\" line=\"0\" value=\"sim\"/>"
    ret+="<data column=\"2\" line=\"0\" value=\"in\"/>"
    ret+="<data column=\"3\" line=\"0\" value=\"in2\"/>"
    ret+="<data column=\"4\" line=\"0\" value=\"intyp\"/>"
    ret+="<data column=\"5\" line=\"0\" value=\"out\"/>"
    ret+="<data column=\"6\" line=\"0\" value=\"out2\"/>"
    ret+="<data column=\"7\" line=\"0\" value=\"outtyp\"/>"
    ret+="<data column=\"8\" line=\"0\" value=\"evtin\"/>"
    ret+="<data column=\"9\" line=\"0\" value=\"evtout\"/>"
    ret+="<data column=\"10\" line=\"0\" value=\"state\"/>"
    ret+="<data column=\"11\" line=\"0\" value=\"dstate\"/>"
    ret+="<data column=\"12\" line=\"0\" value=\"odstate\"/>"
    ret+="<data column=\"13\" line=\"0\" value=\"rpar\"/>"
    ret+="<data column=\"14\" line=\"0\" value=\"ipar\"/>"
    ret+="<data column=\"15\" line=\"0\" value=\"opar\"/>"
    ret+="<data column=\"16\" line=\"0\" value=\"blocktype\"/>"
    ret+="<data column=\"17\" line=\"0\" value=\"firing\"/>"
    ret+="<data column=\"18\" line=\"0\" value=\"dep_ut\"/>"
    ret+="<data column=\"19\" line=\"0\" value=\"label\"/>"
    ret+="<data column=\"20\" line=\"0\" value=\"nzcross\"/>"
    ret+="<data column=\"21\" line=\"0\" value=\"nmode\"/>"
    ret+="<data column=\"22\" line=\"0\" value=\"equations\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"output\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"-1.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"-2.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"-1.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<Array scilabClass=\"ScilabList\"/>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"2.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<Array scilabClass=\"ScilabList\"/>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"c\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"0\" width=\"0\"/>"
    ret+="<ScilabBoolean height=\"1\" width=\"2\">"
    ret+="<data column=\"0\" line=\"0\" value=\"false\"/>"
    ret+="<data column=\"1\" line=\"0\" value=\"false\"/>"
    ret+="</ScilabBoolean>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"}output2\"/>"
    ret+="</ScilabString>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"0.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<ScilabDouble height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" realPart=\"0.0\"/>"
    ret+="</ScilabDouble>"
    ret+="<Array scilabClass=\"ScilabList\"/></Array>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"OUT_f\"/>"
    ret+="</ScilabString>"
    ret+="<Array scilabClass=\"ScilabList\">"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"}output2\"/>"
    ret+="</ScilabString>"
    ret+="</Array>"
    ret+="</Array>"
    ret+="</Array>"
    ret+="<ScilabString height=\"1\" width=\"1\">"
    ret+="<data column=\"0\" line=\"0\" value=\"\"/>"
    ret+="</ScilabString>"
    ret+="<Array scilabClass=\"ScilabList\"/></Array>"
    ret+="<Array as=\"oDState\" scilabClass=\"ScilabList\"/>"
    ret+="<Array as=\"equations\" scilabClass=\"ScilabList\"/>"
    ret+="<mxGeometry as=\"geometry\" height=\"#{([contip, contop].max*40)+36}.0\" width=\"260.0\" x=\"#{(child_number*(300+80))+100}.0\" y=\"20.0\"/>"
    ret+="</SuperBlock>"

    ret+="<!-- Puertos 	 (fuera) -->"
    contop=0
    contip=0
    self.connectors.each{|c|
      c.sub_system_flows.each{|f|
        ret,contop,contip=f.to_xcos_out(ret,contop,contip,already_linked)
      }
    }
    ret+="<mxCell connectable=\"0\" id=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.full_name}#identifier\" parent=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.full_name}\" style=\"noLabel=0;opacity=0\" value=\"#{self.name}\" vertex=\"1\">"
    ret+="<mxGeometry as=\"geometry\" x=\"130.0\" y=\"#{(([contip, contop].max*40)+(36*2))/2}.0\"/>"
    ret+="</mxCell>"

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
      ret=self.project.public || self.layer_visible_by?(acting_user)
    end
    return ret
  end

end
