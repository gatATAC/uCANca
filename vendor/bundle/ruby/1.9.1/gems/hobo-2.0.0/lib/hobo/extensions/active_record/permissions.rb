ActiveRecord::Associations::HasManyAssociation.class_eval do

  # Helper - the user acting on the owner (if there is one)
  def acting_user
    @owner.acting_user if @owner.is_a?(Hobo::Model)
  end


  def delete_records(records, method)
    if method == :destroy
      records.each { |r| r.is_a?(Hobo::Model) ? r.user_destroy(acting_user) : r.destroy }
      update_counter(-records.length) unless inverse_updates_counter_cache?
    else
      keys  = records.map { |r| r[reflection.association_primary_key] }
      scope = scoped.where(reflection.association_primary_key => keys)

      if method == :delete_all
        update_counter(-scope.delete_all)
      else
        update_counter(-scope.update_all(reflection.foreign_key => nil))
      end
    end
  end


  # Set the fkey used by this has_many to null on the passed records, checking for permission first if both the owner
  # and record in question are Hobo models
  def nullify_keys(records)
    if (user = acting_user)
      records.each { |r| r.user_update_attributes!(user, @reflection.foreign_key => nil) if r.is_a?(Hobo::Model) }
    end

    # Normal ActiveRecord implementatin
    ids = records.map { |record| record.quoted_id }.join(',')
    @reflection.klass.update_all(
      "#{@reflection.foreign_key} = NULL",
      "#{@reflection.foreign_key} = #{@owner.quoted_id} AND #{@reflection.klass.primary_key} IN (#{ids})"
    )
  end


  def insert_record_with_owner_attributes(record, force = true, raise = false)
    set_owner_attributes(record)
    if (user = acting_user) && record.is_a?(Hobo::Model)
      if respond_to?(:with_acting_user)
        with_acting_user(user) { insert_record_without_owner_attributes(record, force, raise) }
      else
        record.with_acting_user(user) { insert_record_without_owner_attributes(record, force, raise) }
      end
    else
      insert_record_without_owner_attributes(record, force, raise)
    end
  end
  alias_method_chain :insert_record, :owner_attributes

  def viewable_by?(user, field=nil)
    # view check on an example member record is not supported on associations with conditions
    return true if @reflection.options[:conditions]
    new_candidate.viewable_by?(user, field)
  end

end

ActiveRecord::Associations::HasManyThroughAssociation.class_eval do

  def acting_user
    @owner.acting_user if @owner.is_a?(Hobo::Model)
  end


  def create_record_with_user_create(attrs, options, raise = false, &block)
    klass = @reflection.klass
    user = acting_user if klass < Hobo::Model
    if user
      if attributes.is_a?(Array)
        attributes.collect { |attr| create_record(attr, options, raise, &block) }
      else
        transaction do
          add_to_target(klass.user_create(attributes)) do |record|
            yield(record) if block_given?
            insert_record(record, true, raise)
          end
        end
      end
    else
      create_record_without_user_create(attrs, options, raise, &block)
    end
  end
  alias_method_chain :create_record, :user_create


  def insert_record_with_owner_attributes(record, force = true, raise = false)
    if (user = acting_user) && record.is_a?(Hobo::Model)
      with_acting_user(user) { insert_record_without_owner_attributes(record, force, raise) }
    else
      insert_record_without_owner_attributes(record, force, raise)
    end
    # the following code was in Hobo 1.3, but isn't required if you have the :inverse_of option set
    # klass = @reflection.through_reflection.klass
    # @owner.send(@reflection.through_reflection.name).proxy_target << klass.send(:with_scope, :create => construct_join_attributes(record)) { user ? klass.user_create!(user) : klass.create! }
  end
  alias_method_chain :insert_record, :owner_attributes

  # TODO - add dependent option support
  def delete_records_with_hobo_permission_check(records, method)
    klass  = @reflection.through_reflection.klass
    user = acting_user
    if user && records.any? { |r|
        joiner = klass.where(construct_join_attributes(r)).first
        joiner.is_a?(Hobo::Model) && !joiner.destroyable_by?(user)
      }
      raise Hobo::PermissionDeniedError, "#{@owner.class}##{proxy_association.reflection.name}.destroy"
    end
    delete_records_without_hobo_permission_check(records, method)
  end
  alias_method_chain :delete_records, :hobo_permission_check

end

ActiveRecord::Associations::AssociationProxy.class_eval do

  # Helper - the user acting on the owner (if there is one)
  def acting_user
    @owner.acting_user if @owner.is_a?(Hobo::Model)
  end

  def create(attrs = {})
    if attrs.is_a?(Array)
      attrs.collect { |attr| create(attr) }
    else
      create_record(attrs) do |record|
        yield(record) if block_given?
        user = acting_user if record.is_a?(Hobo::Model)
        user ? record.user_save(user) : record.save
      end
    end
  end

  def create!(attrs = {})
    create_record(attrs) do |record|
      yield(record) if block_given?
      user = acting_user if record.is_a?(Hobo::Model)
      user ? record.user_save!(user) : record.save!
    end
  end

end

