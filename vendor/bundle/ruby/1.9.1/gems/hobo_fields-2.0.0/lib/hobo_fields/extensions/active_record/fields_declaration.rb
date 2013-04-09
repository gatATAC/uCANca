ActiveRecord::Base.class_eval do

    def self.fields(include_in_migration = true, &b)
      # Any model that calls 'fields' gets a bunch of other
      # functionality included automatically, but make sure we only
      # include it once
      include HoboFields::Model unless HoboFields::Model.in?(included_modules)
      @include_in_migration ||= include_in_migration

      if b
        dsl = HoboFields::FieldDeclarationDsl.new(self)
        if b.arity == 1
          yield dsl
        else
          dsl.instance_eval(&b)
        end
      end
    end


end
