class Requirement < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    object_identifier              :string
    object_level                   :integer
    absolute_number                :integer
    is_a_req                       :boolean
    is_implemented                 :boolean
    created_by                     :string
    created_on                     :date
    customer_req_accept_comments   :string
    customer_req_accepted          :boolean
    last_modified_by               :string
    master_req_acceptance_comments :string
    object_heading                 :string
    object_short_text              :string
    object_text                    :string
    priority                       :string
    is_real_time                   :boolean
    req_source                     :string
    timestamps
  end
  attr_accessible :object_identifier, :object_level, :absolute_number, :is_a_req, :is_implemented, :created_by, :created_on, :customer_req_accept_comments, :customer_req_accepted, :last_modified_by, :master_req_acceptance_comments, :object_heading, :object_short_text, :object_text, :priority, :is_real_time, :req_source, :req_doc_id, :req_criticality_id, :req_target_micro, :req_type, :sw_req_type, :req_created_through

  belongs_to :req_criticality, :inverse_of => :requirements
  belongs_to :req_target_micro, :inverse_of => :requirements
  belongs_to :req_type, :inverse_of => :requirements
  belongs_to :sw_req_type, :inverse_of => :requirements
  belongs_to :req_created_through, :inverse_of => :requirements
  belongs_to :req_doc, :creator => :true, :inverse_of => :requirements
  
  validates :object_identifier, :presence => :true
  validates :req_doc, :presence => :true
  validates :req_type, :presence => :true  
  
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
