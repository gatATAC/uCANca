

class Connector < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    timestamps
  end

  attr_accessible :name, :sub_system_flows,:position

  belongs_to :sub_system, :inverse_of => :connectors
  acts_as_list :scope => :sub_system


  has_many :sub_system_flows, :dependent => :destroy,:order => :position, :inverse_of => :connector
  has_many :output_flows, :class_name => 'SubSystemFlow', :conditions => {:outdir => true},:order => :position
  has_many :input_flows, :class_name => 'SubSystemFlow', :conditions => {:outdir => false},:order => :position


  children :sub_system_flows,:input_flows

  validates :sub_system, :presence => :true
  validates :name, :presence => :true

  def full_name
    sub_system.name+":"+name
  end

  def full_path
    sub_system.full_name+":"+name
  end

  def parent_project
    sub_system.parent_project
  end

  def copy_connector_flows(c)
    cc=c.sub_system_flows.sort_by{|i| i.position}
    cc.each {|f|
      self.copy_flow(f)
    }
  end

  def copy_flow(f)
    newf=f.dup
    newf.position=find_first_free_position
    self.sub_system_flows << newf
    newf.save
  end

  def copy_all_subsystem_flows(s)
    ss=s.connectors.sort_by{|i| i.position}
    ss.each {|c|
      cc=c.sub_system_flows.sort_by{|i| i.position}
      cc.each {|f|
        newf=f.dup
        newf.position=find_first_free_position
        self.sub_system_flows << newf
        newf.save
      }
    }
  end

  def find_first_free_position
    pos=1
    found=sub_system_flows.find_by_position(pos)
    while (found)
      pos=pos+1
      found=sub_system_flows.find_by_position(pos)
    end
    return pos
  end

  def possible_connectors
    ret=[]
    if (sub_system.parent) then
      ret=sub_system.parent.connectors
    end
    return ret
  end

  def possible_individual_flows
    ret=[]
    p=possible_connectors
    p.each { |c|
      ret+= c.sub_system_flows
    }
    return ret
  end
  def to_svg
    yporflujo=40
    alturacaracter=10
    anchuracaracter=6
    maxflujos=[self.input_flows.size,self.output_flows.size].max
    yoffsetcaja=10
    yoffsetflujo=yoffsetcaja+alturacaracter*2
    anchuracaja=200+(self.full_name.length*anchuracaracter)
    alturacaja=(yporflujo*(maxflujos-1))+yoffsetflujo
    xoffsetcaja=200
    ycentrocaja=yoffsetflujo+(alturacaja/2)
    xcentrocaja=(anchuracaja/2)+xoffsetcaja
    alturapagina=alturacaja+yoffsetcaja*2
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
    <a id=\"link_#{self.full_name}\" xlink:href=\"/connectors/#{self.id}\" target=\"_blank\">
      <text
       x=\"#{xcentrocaja}\"
       y=\"#{ycentrocaja}\"
       id=\"text_#{self.name}\"
       xml:space=\"preserve\"
       style=\"font-size:16px;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-align:center;line-height:100%;letter-spacing:0px;word-spacing:0px;writing-mode:lr-tb;text-anchor:middle;fill:#000000;fill-opacity:1;stroke:none;font-family:Sans;-inkscape-font-specification:Sans\"><tspan
         x=\"#{xcentrocaja}\"
         y=\"#{ycentrocaja}\"
         id=\"tspan_#{self.full_name}\">#{self.full_name}</tspan></text></a>"


    contador=1;
    self.input_flows.each {|f|
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
    contador=1;
    self.output_flows.each {|f|
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
    ret+="
  </g>
</svg>"
    return ret
  end

  # --- Permissions --- #


  def create_permitted?
    sub_system.updatable_by?(acting_user)
  end

  def update_permitted?
    sub_system.updatable_by?(acting_user)
  end

  def destroy_permitted?
    sub_system.destroyable_by?(acting_user)
  end

  def view_permitted?(field)
    sub_system.viewable_by? (acting_user)
  end




  def copy_connector_flows_permitted?
    sub_system.updatable_by?(acting_user)
  end

  def copy_flow_permitted?
    sub_system.updatable_by?(acting_user)
  end

  def copy_all_subsystem_flows_permitted?
    sub_system.updatable_by?(acting_user)
  end

end
