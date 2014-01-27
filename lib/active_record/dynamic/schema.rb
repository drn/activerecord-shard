module ActiveRecord::Dynamic
  class Schema
    class << self

      #
      # Given the input class, establishes
      #
      # @param klass [Class]
      #
      def setup(klass)
        tablename = self.tablename(klass)
        return if ActiveRecord::Dynamic::Core.exists?(tablename)
        self.connection.create_table(tablename) do |table|
          self.schema(klass).setup(table)
          table.timestamps
        end
        self.schema(klass).send(:indexes).each do |index|
          case index
          when Symbol
            connection.add_index(tablename, index)
          when Hash
            index_config = index.first
            index = index_config[0]
            options = index_config[1]
            Self.connection.add_index(tablename, index, options)
          end
        end
      end

      def teardown(klass)
        tablename = self.tablename(klass)
        return if !ActiveRecord::Dynamic::Core.exists?(tablename)
        ActiveRecord::Base.connection.drop_table(tablename)
      end

      protected

        def schema(klass)
          klass.const_get('DynamicSchema')
        end

        def tablename(klass)
          klass.instance_variable_get(:@tablename)
        end

        def connection
          ActiveRecord::Base.connection
        end

    end
  end
end
