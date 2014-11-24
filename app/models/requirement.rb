class Requirement < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    object_identifier              :string
    object_level                   :integer
    object_number                  :string
    absolute_number                :integer
    is_a_req                       :boolean
    is_implemented                 :boolean
    created_by                     :string
    created_on                     :date
    customer_req_accept_comments   :string
    customer_req_accepted          :boolean
    last_modified_by               :string
    last_modified_on               :date
    master_req_acceptance_comments :string
    master_req_accepted            :boolean
    object_heading                 :string
    object_short_text              :string
    object_text                    :text
    priority                       :string
    is_real_time                   :boolean
    req_source                     :string
    timestamps
  end
  attr_accessible :object_identifier, :object_level, :absolute_number, :is_a_req, :is_implemented, :created_by, :created_on, :customer_req_accept_comments, :customer_req_accepted, :last_modified_by, :master_req_acceptance_comments, :object_heading, :object_short_text, :object_text, :priority, :is_real_time, :req_source, :req_doc_id, :req_criticality_id, :req_target_micro, :req_type, :sw_req_type, :req_created_through, :object_number, :master_req_accepted, :last_modified_on

  belongs_to :req_criticality, :inverse_of => :requirements
  belongs_to :req_target_micro, :inverse_of => :requirements
  belongs_to :req_type, :inverse_of => :requirements
  belongs_to :sw_req_type, :inverse_of => :requirements
  belongs_to :req_created_through, :inverse_of => :requirements
  belongs_to :req_doc, :creator => :true, :inverse_of => :requirements
  
  has_many :req_links, :dependent => :destroy, :inverse_of => :requirement
  has_many :incoming_links, :class_name => 'ReqLink', :foreign_key => :req_source_id, :inverse_of => :req_source
  
  validates :object_identifier, :presence => :true
  validates :req_doc, :presence => :true
  validates :req_type, :presence => :true  
  
  
  def self.import_attributes
    ret=self.accessible_attributes.clone
    ret.delete("req_doc_id")
    ret.delete("req_doc")
    ret.delete("req_criticality_id")
    #ret.delete("fault_requirement")
    ret.delete("")
    return ret
  end
  
  def title
    ret=""
    if (self.object_heading!=nil) then
      ret=self.object_number+": "
      ret+=self.object_identifier
      if (self.object_heading!=nil) then
        ret+=": "+self.object_heading
      end
    end
    ret
  end
  
  def description
    ret=""
    if (self.object_short_text!=nil) then
      ret+=self.object_short_text+":\n"
    end
    if (self.object_text!=nil) then
      ret+=self.object_text
    end
    ret
  end
  
  def column_number
    num_guiones = object_number.count '-'
    if (num_guiones>2) then
      name, match, suffix = object_number.rpartition('-')
      if match!=nil and match!="" then
        ret=suffix.to_i
      else
        ret=0
      end
    else
      ret=0
    end
    ret
  end
  
  # --- Permissions --- #

  def create_permitted?
    if (req_doc) then
      req_doc.updatable_by?(acting_user)
    else
      false
    end
  end

  def update_permitted?
    req_doc.updatable_by?(acting_user)
  end

  def destroy_permitted?
    req_doc.updatable_by?(acting_user)
  end

  def view_permitted?(field)
    ret=self.req_doc.viewable_by?(acting_user)
    return ret
  end

end
