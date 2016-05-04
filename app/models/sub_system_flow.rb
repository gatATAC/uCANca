class SubSystemFlow < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    context_name :string
    timestamps
  end
  attr_accessible :flow, :connector, :connector_id, :flow_id, :position, :flow_direction, :flow_direction_id, :context_name

  belongs_to :flow, :inverse_of => :sub_system_flows, :creator => :true
  belongs_to :connector, :inverse_of => :sub_system_flows, :creator => :true
  belongs_to :flow_direction, :inverse_of => :sub_system_flows

  validates :flow, :presence => :true
  validates :connector, :presence => :true

  acts_as_list :scope => :connector

  def name
    ret=connector.sub_system.full_name+"_"+label
  end

  def label
    if context_name
      context_name
    else
      flow.name
    end
  end
  
  def project
    flow.project
  end

  def sub_system
    connector.sub_system
  end

  def get_tree_data_xml_ssfl()
    ret="<leaf title=\""+self.label+"\" type=\"sub_system_flows\" code=\""+self.id.to_s+"\""+" img=\""+self.flow_direction.img+"\" />\n"
    return ret
  end

  def to_xcos_block(ret,contip,contop,already_linked)
    op=self.flow
    if (self.flow_direction.name=="output" || self.flow_direction.name=="bidir") then
      contop=contop+1
      ret+="<ExplicitOutBlock id=\"out_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name+":"}#{self.connector.name+":"+self.position.to_s}\" ordering=\"#{contop}\" parent=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name}p1\" simulationFunctionType=\"DEFAULT\" style=\"OUT_f;flip=false;mirror=false\" value=\"1\">
              <ScilabString as=\"exprs\" height=\"1\" width=\"1\"><data column=\"0\" line=\"0\" value=\"#{contop}\"/>
              </ScilabString>
              <ScilabDouble as=\"integerParameters\" height=\"1\" width=\"1\"><data column=\"0\" line=\"0\" realPart=\"#{contop}.0\"/></ScilabDouble>
              <Array as=\"objectsParameters\" scilabClass=\"ScilabList\"/>
              <Array as=\"equations\" scilabClass=\"ScilabList\"/>
              <mxGeometry as=\"geometry\" height=\"20.0\" width=\"20.0\" x=\"#{400*([self.sub_system.children.size,1].max)}.0\" y=\"#{(40*contop)+10}.0\"/>
            </ExplicitOutBlock>
            <ExplicitInputPort dataType=\"UNKNOW_TYPE\" id=\"out_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name+":"}#{self.connector.name+":"+self.position.to_s}aux\" ordering=\"1\" parent=\"out_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name+":"}#{self.connector.name+":"+self.position.to_s}\" style=\"ExplicitInputPort;align=left;verticalAlign=middle;spacing=10.0;rotation=0;flip=false;mirror=false\" value=\"\">
              <mxGeometry as=\"geometry\" height=\"8.0\" width=\"8.0\" x=\"-8.0\" y=\"6.0\"/>
            </ExplicitInputPort>
            <mxCell connectable=\"0\" id=\"out_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name+":"}#{self.connector.name+":"+self.position.to_s}#identifier\" parent=\"out_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name+":"}#{self.connector.name+":"+self.position.to_s}\" style=\"noLabel=0;opacity=0\" value=\"#{op.name}\" vertex=\"1\">
              <mxGeometry as=\"geometry\" relative=\"1\" x=\"0.5\" y=\"1.4\"/>
            </mxCell>"
    end
    if (self.flow_direction.name=="input" || self.flow_direction.name=="bidir") then
      contip=contip+1
      ret+="<ExplicitInBlock id=\"in_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name+":"}#{self.connector.name+":"+self.position.to_s}\" ordering=\"#{contip}\" parent=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name}p1\" simulationFunctionType=\"DEFAULT\" style=\"IN_f;flip=false;mirror=false\">
          <ScilabString as=\"exprs\" height=\"1\" width=\"1\"><data column=\"0\" line=\"0\" value=\"#{contip}\"/>
          </ScilabString>
          <ScilabDouble as=\"integerParameters\" height=\"1\" width=\"1\"><data column=\"0\" line=\"0\" realPart=\"#{contip}.0\"/></ScilabDouble>
          <Array as=\"objectsParameters\" scilabClass=\"ScilabList\"/>
          <Array as=\"equations\" scilabClass=\"ScilabList\"/>
          <mxGeometry as=\"geometry\" height=\"20.0\" width=\"20.0\" x=\"40.0\" y=\"#{(40*contip)+10}.0\"/>
        </ExplicitInBlock>
        <ExplicitOutputPort dataType=\"UNKNOW_TYPE\" id=\"in_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name+":"}#{self.connector.name+":"+self.position.to_s}aux\" ordering=\"1\" parent=\"in_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name+":"}#{self.connector.name+":"+self.position.to_s}\" style=\"ExplicitOutputPort;align=right;verticalAlign=middle;spacing=10.0;rotation=0;flip=false;mirror=false\" value=\"\"><mxGeometry as=\"geometry\" height=\"8.0\" width=\"8.0\" x=\"20.0\" y=\"6.0\"/>
        </ExplicitOutputPort>
        <mxCell connectable=\"0\" id=\"in_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name+":"}#{self.connector.name+":"+self.position.to_s}#identifier\" parent=\"in_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name+":"}#{self.connector.name+":"+self.position.to_s}\" style=\"noLabel=0;opacity=0\" value=\"#{op.name}\" vertex=\"1\"><mxGeometry as=\"geometry\" relative=\"1\" x=\"0.5\" y=\"1.4\"/>
        </mxCell>"
    end
    if (self.flow_direction.name=="bidir")
      # We will only connect through the subsystem those bidir that have no children ports with same direction & name
      flag_connect=true
      self.sub_system.children.each {|ssc|
        ssc.sub_system_flows.each{|ssf|
          if (ssf.flow==self.flow || already_linked.include?(self))
            flag_connect=false
            break
          end
        }
      }
      if (flag_connect)
	already_linked += [self]
        ret+="
          <ExplicitLink id=\"link_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name+":"}#{self.connector.name+":"+self.position.to_s}\">
            <mxGeometry as=\"geometry\">
              <mxPoint as=\"sourcePoint\" x=\"60.0\" y=\"250.0\"/>
              <mxPoint as=\"targetPoint\" x=\"230.0\" y=\"130.0\"/>
            </mxGeometry>
            <mxCell as=\"parent\" id=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name}p1\" parent=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name}p0\"/>
            <ExplicitOutputPort as=\"source\" dataType=\"UNKNOW_TYPE\" id=\"in_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name+":"}#{self.connector.name+":"+self.position.to_s}aux\" ordering=\"1\" parent=\"in_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name+":"}#{self.connector.name+":"+self.position.to_s}\" style=\"ExplicitOutputPort;align=right;verticalAlign=middle;spacing=10.0;rotation=0;flip=false;mirror=false\" value=\"\">
              <mxGeometry as=\"geometry\" height=\"8.0\" width=\"8.0\" x=\"20.0\" y=\"6.0\"/>
            </ExplicitOutputPort>
            <ExplicitInputPort as=\"target\" dataType=\"UNKNOW_TYPE\" id=\"out_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name+":"}#{self.connector.name+":"+self.position.to_s}aux\" ordering=\"1\" parent=\"out_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name+":"}#{self.connector.name+":"+self.position.to_s}\" style=\"ExplicitInputPort;align=left;verticalAlign=middle;spacing=10.0;rotation=0;flip=false;mirror=false\" value=\"\">
              <mxGeometry as=\"geometry\" height=\"8.0\" width=\"8.0\" x=\"-8.0\" y=\"6.0\"/>
            </ExplicitInputPort>
          </ExplicitLink>"
      end
    end
    return ret,contip,contop,already_linked
  end

  def to_xcos_out(ret,contip,contop,already_linked)
    op=self.flow
    if (self.flow_direction.name=="output" || self.flow_direction.name=="bidir") then
      contop=contop+1
      ret+="<ExplicitOutputPort dataColumns=\"1\" dataLines=\"1\" dataType=\"REAL_MATRIX\" id=\"out_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name+":"+self.connector.name+":"+self.position.to_s}b2\" ordering=\"#{contop}\" parent=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name}\" style=\"ExplicitOutputPort;align=right;verticalAlign=middle;spacing=10.0;rotation=0;flip=false;mirror=false\" value=\"#{op.name}\">
                  <mxGeometry as=\"geometry\" height=\"8.0\" width=\"8.0\" x=\"260.0\" y=\"#{((40*(contop-1))+36)}.0\"/>
                </ExplicitOutputPort>"
      # Let's search for an output with same flow in the parent
      ssp=self.sub_system.parent
      if (ssp!=nil)
        ssp.output_flows.each{|ssf|
          if (ssf.flow==self.flow && ssf!=self && !already_linked.include?(self))# && ssf.flow_direction.name!="bidir")
            # There is an output flow with same flow, so we have to connect this output to the parent's one:
            ret+="
                            <ExplicitLink id=\"link_out_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name+":"+self.connector.name+":"+self.position.to_s}\" >
                                <mxGeometry as=\"geometry\">
                                    <mxPoint as=\"sourcePoint\" x=\"360.0\" y=\"180.0\"/>
                                    <mxPoint as=\"targetPoint\" x=\"440.0\" y=\"180.0\"/>
                                </mxGeometry>
                                <mxCell as=\"parent\" id=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+ssp.full_name}p1\" parent=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+ssp.full_name}p0\"/>
                                <ExplicitOutputPort as=\"source\" dataType=\"UNKNOW_TYPE\" id=\"out_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name+":"}#{self.connector.name+":"+self.position.to_s}b2\" ordering=\"2\" parent=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name}\" style=\"ExplicitOutputPort;align=right;verticalAlign=middle;spacing=10.0;rotation=0;flip=false;mirror=false\" value=\"#{self.label}\">
                                    <mxGeometry as=\"geometry\" height=\"8.0\" width=\"8.0\" x=\"260.0\" y=\"#{((40*(contop-1))+36)}.0\"/>
                                </ExplicitOutputPort>
                                <ExplicitInputPort as=\"target\" dataType=\"UNKNOW_TYPE\" id=\"out_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+ssp.full_name+":"}#{ssf.connector.name+":"+ssf.position.to_s}aux\" ordering=\"1\" parent=\"out_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+ssp.full_name+":"}#{ssf.connector.name+":"+ssf.position.to_s}\" style=\"ExplicitInputPort;align=left;verticalAlign=middle;spacing=10.0;rotation=0;flip=false;mirror=false\" value=\"\">
                                    <mxGeometry as=\"geometry\" height=\"8.0\" width=\"8.0\" x=\"-8.0\" y=\"6.0\"/>
                                </ExplicitInputPort>
                            </ExplicitLink>
            "
		already_linked +=  [self]
          end
        }

        # Let's search for an output with same flow in the sibling subsystems
        ssp.children.each{|sss|
          if (sss!=self.sub_system)
            contssf=0
            sss.input_flows.each{|ssf|
              contssf+=1
              if (ssf.flow==self.flow && ssf!=self && !already_linked.include?(self))# && ssf.flow_direction.name!="bidir")
                # There is an output flow with same flow, so we have to connect this output to the parent's one:
                ret+="
                                <ExplicitLink id=\"link_sibout_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name+":"+self.connector.name+":"+self.position.to_s}\" >
                                    <mxGeometry as=\"geometry\">
                                        <mxPoint as=\"sourcePoint\" x=\"360.0\" y=\"180.0\"/>
                                        <mxPoint as=\"targetPoint\" x=\"440.0\" y=\"180.0\"/>
                                    </mxGeometry>
                                    <mxCell as=\"parent\" id=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+ssp.full_name}p1\" parent=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+ssp.full_name}p0\"/>
                                    <ExplicitOutputPort as=\"source\" dataType=\"UNKNOW_TYPE\" id=\"out_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name+":"}#{self.connector.name+":"+self.position.to_s}b2\" ordering=\"2\" parent=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name}\" style=\"ExplicitOutputPort;align=right;verticalAlign=middle;spacing=10.0;rotation=0;flip=false;mirror=false\" value=\"#{self.label}\">
                                        <mxGeometry as=\"geometry\" height=\"8.0\" width=\"8.0\" x=\"260.0\" y=\"#{((40*(contop-1))+36)}.0\"/>
                                    </ExplicitOutputPort>
                                    <ExplicitInputPort as=\"target\" dataType=\"UNKNOW_TYPE\" id=\"in_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+ssf.sub_system.full_name+":"}#{ssf.connector.name+":"+ssf.position.to_s}b2\" ordering=\"2\" parent=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name}\" style=\"ExplicitInputPort;align=left;verticalAlign=middle;spacing=10.0;rotation=0;flip=false;mirror=false\" value=\"#{ssf.label}\">
                                        <mxGeometry as=\"geometry\" height=\"8.0\" width=\"8.0\" x=\"-8.0\" y=\"#{((40*(contssf-1))+36)}.0\"/>
                                    </ExplicitInputPort>
                                </ExplicitLink>
                "
		already_linked += [self]
              end
            }
          end
        }
      end  
    end
    if (self.flow_direction.name=="input" || self.flow_direction.name=="bidir") then
      contip=contip+1
      ret+="<ExplicitInputPort dataColumns=\"1\" dataLines=\"1\" dataType=\"REAL_MATRIX\" id=\"in_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name+":"+self.connector.name+":"+self.position.to_s}b2\" ordering=\"#{contip}\" parent=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name}\" style=\"ExplicitInputPort;align=left;verticalAlign=middle;spacing=10.0;rotation=0;flip=false;mirror=false\" value=\"#{op.name}\">
                <mxGeometry as=\"geometry\" height=\"8.0\" width=\"8.0\" x=\"-8.0\" y=\"#{((40*(contip-1))+36)}.0\"/>
            </ExplicitInputPort>"

      # Let's search for an input with same flow in the parent
      #      if (self.flow_direction.name!="bidir")
      ssp=self.sub_system.parent
      if (ssp!=nil)
        ssp.input_flows.each{|ssf|
          if (ssf.flow==self.flow && ssf!=self && !already_linked.include?(self))# && ssf.flow_direction.name!="bidir")
            # There is an input flow with same flow, so we have to connect this output to the parent's one:
            ret+="
                            <ExplicitLink id=\"link_in_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name+":"+self.connector.name+":"+self.position.to_s}\" >
                                <mxGeometry as=\"geometry\">
                                    <mxPoint as=\"sourcePoint\" x=\"40.0\" y=\"180.0\"/>
                                    <mxPoint as=\"targetPoint\" x=\"100.0\" y=\"180.0\"/>
                                </mxGeometry>
                                <mxCell as=\"parent\" id=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+ssp.full_name}p1\" parent=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+ssp.full_name}p0\"/>
                                <ExplicitOutputPort as=\"source\" dataType=\"UNKNOW_TYPE\" id=\"in_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+ssp.full_name+":"}#{ssf.connector.name+":"+ssf.position.to_s}aux\" ordering=\"1\" parent=\"in_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+ssp.full_name+":"}#{ssf.connector.name+":"+ssf.position.to_s}\" style=\"ExplicitOutputPort;align=right;verticalAlign=middle;spacing=10.0;rotation=0;flip=false;mirror=false\" value=\"\">
                                    <mxGeometry as=\"geometry\" height=\"8.0\" width=\"8.0\" x=\"20.0\" y=\"6.0\"/>
                                </ExplicitOutputPort>
                                <ExplicitInputPort as=\"target\" dataType=\"UNKNOW_TYPE\" id=\"in_#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name+":"}#{self.connector.name+":"+self.position.to_s}b2\" ordering=\"2\" parent=\"#{self.project.abbrev+"file:"+self.project.abbrev+"Block:"+self.sub_system.full_name}\" style=\"ExplicitInputPort;align=left;verticalAlign=middle;spacing=10.0;rotation=0;flip=false;mirror=false\" value=\"#{self.label}\">
                                    <mxGeometry as=\"geometry\" height=\"8.0\" width=\"8.0\" x=\"-8.0\" y=\"#{((40*(contip-1))+36)}.0\"/>
                                </ExplicitInputPort>
                            </ExplicitLink>
            "
	    already_linked += [self]
          end
        }
      end  
      #      end
    end    

    return ret,contip,contop,already_linked
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
