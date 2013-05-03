class SubSystemFlow < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
  end
  attr_accessible :flow, :connector, :connector_id, :flow_id, :position, :flow_direction, :flow_direction_id

  belongs_to :flow, :inverse_of => :sub_system_flows, :creator => :true
  belongs_to :connector, :inverse_of => :sub_system_flows, :creator => :true
  belongs_to :flow_direction, :inverse_of => :sub_system_flows

  validates :flow, :presence => :true
  validates :connector, :presence => :true

  acts_as_list :scope => :connector

  def name
    ret=connector.sub_system.full_name+"_"+flow.name
  end

  def project
    flow.project
  end

  def sub_system
    connector.sub_system
  end

  def get_tree_data_xml_ssfl()
    ret="<leaf title=\""+self.flow.name+"\" type=\"sub_system_flows\" code=\""+self.id.to_s+"\""+" img=\""+self.flow_direction.img+"\" />\n"
    return ret
  end

  def to_xcos_block(ret,contip,contop)
    op=self.flow
    if (self.flow_direction.name=="output") then
      contop=contop+1
      ret+="<ExplicitOutBlock id=\"#{project.name+"file:"+project.name+"Block:"+self.sub_system.full_name+":"}#{connector.name+":"+self.position.to_s}\" ordering=\"#{contop}\" parent=\"#{project.name+"file:"+project.name+"Block:"+self.sub_system.full_name}p1\" simulationFunctionType=\"DEFAULT\" style=\"OUT_f;flip=false;mirror=false\" value=\"1\"><ScilabString as=\"exprs\" height=\"1\" width=\"1\"><data column=\"0\" line=\"0\" value=\"#{contop}\"/></ScilabString><ScilabDouble as=\"integerParameters\" height=\"1\" width=\"1\"><data column=\"0\" line=\"0\" realPart=\"#{contop}.0\"/></ScilabDouble><Array as=\"objectsParameters\" scilabClass=\"ScilabList\"/><Array as=\"equations\" scilabClass=\"ScilabList\"/><mxGeometry as=\"geometry\" height=\"20.0\" width=\"20.0\" x=\"240.0\" y=\"#{40*contop}.0\"/></ExplicitOutBlock><ExplicitInputPort dataType=\"UNKNOW_TYPE\" id=\"#{project.name+"file:"+project.name+"Block:"+self.sub_system.full_name+":"}#{connector.name+":"+self.position.to_s}1aux\" ordering=\"1\" parent=\"#{project.name+"file:"+project.name+"Block:"+self.sub_system.full_name+":"}#{connector.name+":"+self.position.to_s}\" style=\"ExplicitInputPort;align=left;verticalAlign=middle;spacing=10.0;rotation=0;flip=false;mirror=false\" value=\"\"><mxGeometry as=\"geometry\" height=\"8.0\" width=\"8.0\" x=\"-8.0\" y=\"6.0\"/></ExplicitInputPort><mxCell connectable=\"0\" id=\"#{project.name+"file:"+project.name+"Block:"+self.sub_system.full_name+":"}#{connector.name+":"+self.position.to_s}#identifier\" parent=\"#{project.name+"file:"+project.name+"Block:"+self.sub_system.full_name+":"}#{connector.name+":"+self.position.to_s}\" style=\"noLabel=0;opacity=0\" value=\"#{op.name}\" vertex=\"1\"><mxGeometry as=\"geometry\" relative=\"1\" x=\"0.5\" y=\"1.4\"/></mxCell>"
    else
      if (self.flow_direction.name=="input") then
        contip=contip+1
        ret+="<ExplicitInBlock id=\"#{project.name+"file:"+project.name+"Block:"+self.sub_system.full_name+":"}#{connector.name+":"+self.position.to_s}\" ordering=\"#{contip}\" parent=\"#{project.name+"file:"+project.name+"Block:"+self.sub_system.full_name}p1\" simulationFunctionType=\"DEFAULT\" style=\"IN_f;flip=false;mirror=false\"><ScilabString as=\"exprs\" height=\"1\" width=\"1\"><data column=\"0\" line=\"0\" value=\"#{contip}\"/></ScilabString><ScilabDouble as=\"integerParameters\" height=\"1\" width=\"1\"><data column=\"0\" line=\"0\" realPart=\"#{contip}.0\"/></ScilabDouble><Array as=\"objectsParameters\" scilabClass=\"ScilabList\"/><Array as=\"equations\" scilabClass=\"ScilabList\"/><mxGeometry as=\"geometry\" height=\"20.0\" width=\"20.0\" x=\"40.0\" y=\"#{40*contip}.0\"/></ExplicitInBlock><ExplicitOutputPort dataType=\"UNKNOW_TYPE\" id=\"#{project.name+"file:"+project.name+"Block:"+self.sub_system.full_name+":"}#{connector.name+":"+self.position.to_s}aux\" ordering=\"1\" parent=\"#{project.name+"file:"+project.name+"Block:"+self.sub_system.full_name+":"}#{connector.name+":"+self.position.to_s}\" style=\"ExplicitOutputPort;align=right;verticalAlign=middle;spacing=10.0;rotation=0;flip=false;mirror=false\" value=\"\"><mxGeometry as=\"geometry\" height=\"8.0\" width=\"8.0\" x=\"20.0\" y=\"6.0\"/></ExplicitOutputPort><mxCell connectable=\"0\" id=\"#{project.name+"file:"+project.name+"Block:"+self.sub_system.full_name+":"}#{connector.name+":"+self.position.to_s}#identifier\" parent=\"#{project.name+"file:"+project.name+"Block:"+self.sub_system.full_name+":"}#{connector.name+":"+self.position.to_s}\" style=\"noLabel=0;opacity=0\" value=\"#{op.name}\" vertex=\"1\"><mxGeometry as=\"geometry\" relative=\"1\" x=\"0.5\" y=\"1.4\"/></mxCell>"
      end
    end
    return ret,contip,contop
  end

  def to_xcos_out(ret,contip,contop)
    op=self.flow
    if (self.flow_direction.name=="output") then
      contop=contop+1
          ret+="<ExplicitOutputPort dataColumns=\"1\" dataLines=\"1\" dataType=\"REAL_MATRIX\" id=\"#{self.project.name+"file:"+self.project.name+"Block:"+self.sub_system.full_name+":"+self.connector.name+":"+self.position.to_s}b2\" ordering=\"#{contop}\" parent=\"#{self.project.name+"file:"+self.project.name+"Block:"+self.sub_system.full_name}\" style=\"ExplicitOutputPort;align=right;verticalAlign=middle;spacing=10.0;rotation=0;flip=false;mirror=false\" value=\"#{op.name}\"><mxGeometry as=\"geometry\" height=\"8.0\" width=\"8.0\" x=\"260.0\" y=\"#{((40*(contop-1))+36)}.0\"/></ExplicitOutputPort>"
    else
      if (self.flow_direction.name=="input") then
        contip=contip+1
        ret+="<ExplicitInputPort dataColumns=\"1\" dataLines=\"1\" dataType=\"REAL_MATRIX\" id=\"#{self.project.name+"file:"+self.project.name+"Block:"+self.sub_system.full_name+":"+self.connector.name+":"+self.position.to_s}b2\" ordering=\"#{contip}\" parent=\"#{self.project.name+"file:"+self.project.name+"Block:"+self.sub_system.full_name}\" style=\"ExplicitInputPort;align=left;verticalAlign=middle;spacing=10.0;rotation=0;flip=false;mirror=false\" value=\"#{op.name}\"><mxGeometry as=\"geometry\" height=\"8.0\" width=\"8.0\" x=\"-8.0\" y=\"#{((40*(contip-1))+36)}.0\"/></ExplicitInputPort>"
      end
    end
    return ret,contip,contop
  end

  # --- Permissions --- #

  def create_permitted?
    connector.updatable_by?(acting_user)
  end

  def update_permitted?
    connector.updatable_by?(acting_user)
  end

  def destroy_permitted?
    connector.destroyable_by?(acting_user)
  end

  def view_permitted?(field)
    connector.viewable_by? (acting_user)
  end

end
