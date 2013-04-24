class SubSystem < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    abbrev :string
    timestamps
  end
  attr_accessible :name, :parent, :root, :parent_id, :root_id, :layer, :layer_id, :abbrev, :project, :project_id


  belongs_to :project
  belongs_to :layer
  belongs_to :root, :class_name => 'SubSystem'
  belongs_to :parent,  :creator => true, :foreign_key => :parent_id, :class_name => 'SubSystem'

  validates :name, :presence => :true
  validates :abbrev, :presence => :true

  has_many :children, :foreign_key => :parent_id, :class_name => 'SubSystem', :order => :position

  has_many :connectors, :order => :position

  has_many :output_flows, :through => :connectors, :class_name => 'SubSystemFlow', :conditions => {:outdir => true}
  has_many :input_flows, :through => :connectors, :class_name => 'SubSystemFlow', :conditions => {:outdir => false}

  has_many :function_sub_systems, :inverse_of => :sub_system, :order => :position
  has_many :functions, :through => :function_sub_systems

  validates :layer, :presence => :true

  children :connectors,:children, :function_sub_systems

  acts_as_list :scope => :parent

  def parent_project
    ret = nil
    if root then
      ret=root.parent_project
    else
      if parent then
        ret=parent.parent_project
      else
        ret=project
      end
    end
    return ret
  end

  def full_name
    ret=name
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
    return sources.size > 0
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

  def to_svg
    yporflujo=40
    alturacaracter=10
    anchuracaracter=6
    maxflujos=[self.input_flows.size,self.output_flows.size].max
    yoffsetcaja=10
    yoffsetflujo=yoffsetcaja*2+alturacaracter*2
    anchuracaja=200+(self.full_name.length*anchuracaracter)
    alturacaja=(yporflujo*(maxflujos))+(alturacaracter*2)
    xoffsetcaja=200
    ycentrocaja=yoffsetflujo+(alturacaja/2)
    xcentrocaja=(anchuracaja/2)+xoffsetcaja
    alturapagina=alturacaja+yoffsetcaja*2

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
       height=\"#{alturacaja}\"
       x=\"#{xoffsetcaja}\"
       y=\"#{yoffsetcaja}\"
       id=\"rect_#{self.name}\"
       style=\"fill:none;stroke:#000000;stroke-width:0.34495062;stroke-opacity:1\" />
    <a id=\"link_#{self.full_name}\" xlink:href=\"/sub_systems/#{self.id}\" target=\"_blank\">
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
       width=\"#{anchuracaracter*(f.flow.name.length+2)}\"
       height=\"1\"
       x=\"#{xoffsetcaja-(anchuracaracter*(f.flow.name.length+2))}\"
       y=\"#{(yporflujo*(contador-1))+yoffsetflujo}\"
       id=\"line_#{f.flow.name}\"
       style=\"fill:none;stroke:#000000;stroke-width:0.65142924;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none\" />
    <a xlink:href=\"/flows/#{f.flow.id}\" target=\"_blank\">
  <text
       x=\"#{xoffsetcaja-anchuracaracter}\"
       y=\"#{(yporflujo*(contador-1))+(yoffsetflujo-alturacaracter)}\"
       id=\"text_#{f.flow.name}\"
       xml:space=\"preserve\"
       style=\"font-size:10px;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-align:end;line-height:100%;letter-spacing:0px;word-spacing:0px;writing-mode:lr-tb;text-anchor:end;fill:#000000;fill-opacity:1;stroke:none;font-family:Sans;-inkscape-font-specification:Sans\">
       <tspan
         x=\"#{xoffsetcaja-anchuracaracter}\"
         y=\"#{(yporflujo*(contador-1))+(yoffsetflujo-alturacaracter)}\"
         id=\"tspan_#{f.flow.name}\">#{f.flow.name}</tspan></text>  </a>";
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
    <a id=\"link_#{c.full_name}\" xlink:href=\"/connectors/#{c.id}\" target=\"_blank\">
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
       width=\"#{anchuracaracter*(f.flow.name.length+2)}\"
       height=\"1\"
       x=\"#{xoffsetcaja+anchuracaja}\"
       y=\"#{(yporflujo*(contador-1))+yoffsetflujo}\"
       id=\"line_#{f.flow.name}\"
       style=\"fill:none;stroke:#000000;stroke-width:0.65142924;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none\" />
    <a xlink:href=\"/flows/#{f.flow.id}\" target=\"_blank\">
    <text
       x=\"#{xoffsetcaja+anchuracaja+anchuracaracter}\"
       y=\"#{(yporflujo*(contador-1))+(yoffsetflujo-alturacaracter)}\"
       id=\"text_#{f.flow.name}\"
       xml:space=\"preserve\"
       style=\"font-size:10px;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-align:start;line-height:100%;letter-spacing:0px;word-spacing:0px;writing-mode:lr-tb;text-anchor:start;fill:#000000;fill-opacity:1;stroke:none;font-family:Sans;-inkscape-font-specification:Sans\">
       <tspan
         x=\"#{xoffsetcaja+anchuracaja+anchuracaracter}\"
         y=\"#{(yporflujo*(contador-1))+(yoffsetflujo-alturacaracter)}\"
         id=\"tspan_#{f.flow.name}\">#{f.flow.name}</tspan></text></a>";
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
    <a id=\"link_#{c.full_name}\" xlink:href=\"/connectors/#{c.id}\" target=\"_blank\">
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
    if parent_project.owner==u then
      ret=true
    else
      parent_project.project_memberships.each  {|mb|
        if (mb.user==u) then
          if (mb.maximum_layer == 0 || mb.maximum_layer>=self.layer.level) then
            ret=true
          end
        end
      }
    end
    return ret
  end

  # --- Permissions --- #

  def create_permitted?
    parent_project.updatable_by?(acting_user)
  end

  def update_permitted?
    parent_project.updatable_by?(acting_user)
  end

  def destroy_permitted?
    parent_project.destroyable_by?(acting_user)
  end

  def view_permitted?(field)
    if parent_project then
      parent_project.viewable_by?(acting_user) && self.layer_visible_by?(acting_user)
    else
      true
    end
  end

end
