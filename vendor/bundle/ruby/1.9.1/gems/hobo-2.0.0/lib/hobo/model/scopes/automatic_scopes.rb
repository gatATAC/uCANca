module Hobo
  module Model
    module Scopes

      module AutomaticScopes

        def create_automatic_scope(name, check_only=false)
          ScopeBuilder.new(self, name).create_scope(check_only)
        rescue ActiveRecord::StatementInvalid => e
          # Problem with the database? Don't try to create automatic
          # scopes
          if ActiveRecord::Base.logger
            ActiveRecord::Base.logger.warn "!! Database exception during hobo auto-scope creation -- continuing automatic scopes"
            ActiveRecord::Base.logger.warn "!! #{e.to_s}"
          end
          false
        end

      end

      # The methods on this module add scopes to the given class
      class ScopeBuilder

        def initialize(klass, name)
          @klass = klass
          @name  = name.to_s
        end

        attr_reader :name

        def create_scope(check_only=false)
          matched_scope = true

          like_operator = ActiveRecord::Base.connection.adapter_name =~ /postg/i ? 'ILIKE' : 'LIKE'

          case
          # --- Association Queries --- #

          # with_players(player1, player2)
          when name =~ /^with_(.*)/ && (refl = reflection($1))
            return true if check_only

            def_scope do |*records|
              if records.empty?
                @klass.where exists_sql_condition(refl, true)
              else
                records = records.flatten.compact.map {|r| find_if_named(refl, r) }
                exists_sql = ([exists_sql_condition(refl)] * records.length).join(" AND ")
                @klass.where *([exists_sql] + records)
              end
            end

          # with_player(a_player)
          when name =~ /^with_(.*)/ && (refl = reflection($1.pluralize))
            return true if check_only

            exists_sql = exists_sql_condition(refl)
            def_scope do |record|
              record = find_if_named(refl, record)
              @klass.where exists_sql, record
            end

          # any_of_players(player1, player2)
          when name =~ /^any_of_(.*)/ && (refl = reflection($1))
            return true if check_only

            def_scope do |*records|
              if records.empty?
                @klass.where exists_sql_condition(refl, true)
              else
                records = records.flatten.compact.map {|r| find_if_named(refl, r) }
                exists_sql = ([exists_sql_condition(refl)] * records.length).join(" OR ")
                @klass.where *([exists_sql] + records)
              end
            end

          # without_players(player1, player2)
          when name =~ /^without_(.*)/ && (refl = reflection($1))
            return true if check_only

            def_scope do |*records|
              if records.empty?
                @klass.where "NOT (#{exists_sql_condition(refl, true)})"
              else
                records = records.flatten.compact.map {|r| find_if_named(refl, r) }
                exists_sql = ([exists_sql_condition(refl)] * records.length).join(" AND ")
                @klass.where *(["NOT (#{exists_sql})"] + records)
              end
            end

          # without_player(a_player)
          when name =~ /^without_(.*)/ && (refl = reflection($1.pluralize))
            return true if check_only

            exists_sql = exists_sql_condition(refl)
            def_scope do |record|
              record = find_if_named(refl, record)
              @klass.where "NOT #{exists_sql}", record
            end

          # team_is(a_team)
          when name =~ /^(.*)_is$/ && (refl = reflection($1)) && refl.macro.in?([:has_one, :belongs_to])
            return true if check_only

            if refl.options[:polymorphic]
              def_scope do |record|
                record = find_if_named(refl, record)
                @klass.where "#{foreign_key_column refl} = ? AND #{$1}_type = ?", record, record.class.name
              end
            else
              def_scope do |record|
                record = find_if_named(refl, record)
                @klass.where "#{foreign_key_column refl} = ?", record
              end
            end

          # team_is_not(a_team)
          when name =~ /^(.*)_is_not$/ && (refl = reflection($1)) && refl.macro.in?([:has_one, :belongs_to])
            return true if check_only

            if refl.options[:polymorphic]
              def_scope do |record|
                record = find_if_named(refl, record)
                @klass.where "#{foreign_key_column refl} <> ? OR #{name}_type <> ?", record, record.class.name
              end
            else
              def_scope do |record|
                record = find_if_named(refl, record)
                @klass.where "#{foreign_key_column refl} <> ?", record
              end
            end


          # --- Column Queries --- #

          # name_is(str)
          when name =~ /^(.*)_is$/ && (col = column($1))
            return true if check_only

            def_scope do |str|
              @klass.where "#{column_sql(col)} = ?", str
            end

          # name_is_not(str)
          when name =~ /^(.*)_is_not$/ && (col = column($1))
            return true if check_only

            def_scope do |str|
              @klass.where "#{column_sql(col)} <> ?", str
            end

          # name_contains(str)
          when name =~ /^(.*)_contains$/ && (col = column($1))
            return true if check_only

            def_scope do |str|
              @klass.where "#{column_sql(col)} #{like_operator} ?", "%#{str}%"
            end

          # name_does_not_contain
          when name =~ /^(.*)_does_not_contain$/ && (col = column($1))
            return true if check_only

            def_scope do |str|
              @klass.where "#{column_sql(col)} NOT #{like_operator} ?", "%#{str}%"
            end

          # name_starts(str)
          when name =~ /^(.*)_starts$/ && (col = column($1))
            return true if check_only

            def_scope do |str|
              @klass.where "#{column_sql(col)} #{like_operator} ?", "#{str}%"
            end

          # name_does_not_start
          when name =~ /^(.*)_does_not_start$/ && (col = column($1))
            return true if check_only

            def_scope do |str|
              @klass.where "#{column_sql(col)} NOT #{like_operator} ?", "#{str}%"
            end

          # name_ends(str)
          when name =~ /^(.*)_ends$/ && (col = column($1))
            return true if check_only

            def_scope do |str|
              @klass.where "#{column_sql(col)} #{like_operator} ?", "%#{str}"
            end

          # name_does_not_end(str)
          when name =~ /^(.*)_does_not_end$/ && (col = column($1))
            return true if check_only

            def_scope do |str|
              @klass.where "#{column_sql(col)} NOT #{like_operator} ?", "%#{str}"
            end

          # published (a boolean column)
          when (col = column(name)) && (col.type == :boolean)
            return true if check_only

            def_scope do
              @klass.where "#{column_sql(col)} = ?", true
            end

          # not_published
          when name =~ /^not_(.*)$/ && (col = column($1)) && (col.type == :boolean)
            return true if check_only

            def_scope do
              @klass.where "#{column_sql(col)} <> ?", true
            end

          # published_before(time)
          when name =~ /^(.*)_before$/ && (col = column("#{$1}_at") || column("#{$1}_date") || column("#{$1}_on")) && col.type.in?([:date, :datetime, :time, :timestamp])
            return true if check_only

            def_scope do |time|
              @klass.where "#{column_sql(col)} < ?", time
            end

          # published_after(time)
          when name =~ /^(.*)_after$/ && (col = column("#{$1}_at") || column("#{$1}_date") || column("#{$1}_on")) && col.type.in?([:date, :datetime, :time, :timestamp])
            return true if check_only

            def_scope do |time|
              @klass.where "#{column_sql(col)} > ?", time
            end

          # published_between(time1, time2)
          when name =~ /^(.*)_between$/ && (col = column("#{$1}_at") || column("#{$1}_date") || column("#{$1}_on")) && col.type.in?([:date, :datetime, :time, :timestamp])
            return true if check_only

            def_scope do |time1, time2|
              @klass.where "#{column_sql(col)} >= ? AND #{column_sql(col)} <= ?", time1, time2
            end

           # active (a lifecycle state)
          when @klass.has_lifecycle? && name.to_sym.in?(@klass::Lifecycle.state_names)
            return true if check_only

            if @klass::Lifecycle.state_names.length == 1
              # nothing to check for - create a dummy scope
              def_scope { @klass.scoped }
              true
            else
              def_scope do
                @klass.where "#{@klass.table_name}.#{@klass::Lifecycle.state_field} = ?", name
              end
            end

          # self is / is not
          when name == "is"
            return true if check_only

            def_scope do |record|
              @klass.where "#{@klass.table_name}.#{@klass.primary_key} = ?", record
            end

          when name == "is_not"
            return true if check_only

            def_scope do |record|
              @klass.where "#{@klass.table_name}.#{@klass.primary_key} <> ?", record
            end


          when name == "by_most_recent"
            return true if check_only

            def_scope do
              @klass.order "#{@klass.table_name}.created_at DESC"
            end

          when name == "recent"
            return true if check_only

            if "created_at".in?(@klass.columns.*.name)
              def_scope do |*args|
                count = args.first || 6
                @klass.order("#{@klass.table_name}.created_at DESC").limit(count)
              end
            else
              def_scope do |*args|
                count = args.first || 6
                limit(count)
              end
            end

          when name == "order_by"
            return true if check_only

            klass = @klass
            def_scope do |*args|
              field, asc = args
              field ||= ""
              type = klass.attr_type(field)
              if type.nil? #a virtual attribute from an SQL alias, e.g., 'total' from 'COUNT(*) AS total'
                colspec = "#{field}" # don't prepend the table name
              elsif type.respond_to?(:name_attribute) && (name = type.name_attribute)
                include = field
                colspec = "#{type.table_name}.#{name}"
              else
                colspec = "#{klass.table_name}.#{field}"
              end
              @klass.includes(include).order("#{colspec} #{asc._?.upcase}")
            end

          when name == "include"
            # DEPRECATED: it clashes with Module.include when called on an ActiveRecord::Relation
            # after a scope chain, if you didn't call it on the class itself first
            Rails.logger.warn "Automatic scope :include has been deprecated: use :includes instead."
            return true if check_only

            def_scope do |inclusions|
              @klass.includes(inclusions)
            end

          when name == "search"
            return true if check_only

            def_scope do |query, *fields|
              match_keyword = %w(PostgreSQL PostGIS).include?(::ActiveRecord::Base.connection.adapter_name) ? "ILIKE" : "LIKE"

              words = (query || "").split
              args = []
              word_queries = words.map do |word|
                field_query = '(' + fields.map { |field|
                  field = "#{@klass.table_name}.#{field}" unless field =~ /\./
                  "(#{field} #{match_keyword} ?)"
                }.join(" OR ") + ')'
                args += ["%#{word}%"] * fields.length
                field_query
              end

              @klass.where *([word_queries.join(" AND ")] + args)
            end

          else
            matched_scope = false
          end

          matched_scope
        end


        def column_sql(column)
          "#{@klass.table_name}.#{column.name}"
        end


        def exists_sql_condition(reflection, any=false)
          owner = @klass
          owner_primary_key = "#{owner.table_name}.#{owner.primary_key}"

          if reflection.options[:through]
            join_table   = reflection.through_reflection.klass.table_name
            owner_fkey   = reflection.through_reflection.foreign_key
            conditions   = reflection.options[:conditions].blank? ? '' : " AND #{reflection.through_reflection.klass.send(:sanitize_sql_for_conditions, reflection.options[:conditions])}"

            if any
              "EXISTS (SELECT * FROM #{join_table} WHERE #{join_table}.#{owner_fkey} = #{owner_primary_key}#{conditions})"
            else
              source_fkey  = reflection.source_reflection.foreign_key
              "EXISTS (SELECT * FROM #{join_table} " +
                "WHERE #{join_table}.#{source_fkey} = ? AND #{join_table}.#{owner_fkey} = #{owner_primary_key}#{conditions})"
            end
          else
            foreign_key = reflection.foreign_key
            related     = reflection.klass
            conditions = reflection.options[:conditions].blank? ? '' : " AND #{reflection.klass.send(:sanitize_sql_for_conditions, reflection.options[:conditions])}"

            if any
              "EXISTS (SELECT * FROM #{related.table_name} " +
                "WHERE #{related.table_name}.#{foreign_key} = #{owner_primary_key}#{conditions})"
            else
              "EXISTS (SELECT * FROM #{related.table_name} " +
                "WHERE #{related.table_name}.#{foreign_key} = #{owner_primary_key} AND " +
                "#{related.table_name}.#{related.primary_key} = ?#{conditions})"
            end
          end
        end

        def find_if_named(reflection, string_or_record)
          if string_or_record.is_a?(String)
            name = string_or_record
            reflection.klass.named(name)
          else
            string_or_record # a record
          end
        end


        def column(name)
          @klass.column(name)
        end


        def reflection(name)
          @klass.reflections[name.to_sym]
        end


        def def_scope(&block)
          @klass.scope name.to_sym, (lambda &block)
        end


        def primary_key_column(refl)
          "#{refl.klass.table_name}.#{refl.klass.primary_key}"
        end


        def foreign_key_column(refl)
          "#{@klass.table_name}.#{refl.foreign_key}"
        end

      end

    end
  end
end
