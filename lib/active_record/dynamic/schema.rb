module ActiveRecord::Dynamic
  class Schema
    class << self

      #
      # Given the input class, establishes
      #
      # @param klass [Class]
      #
      def setup(klass)
        fullname = self.fullname(klass)
        return if self.exists?(fullname)
        self.connection.create_table(fullname) do |table|
          self.schema(klass).setup(table)
          table.timestamps
        end
        self.schema(klass).send(:indexes).each do |index|
          case index
          when Symbol
            connection.add_index(fullname, index)
          when Hash
            index_config = index.first
            index = index_config[0]
            options = index_config[1]
            Self.connection.add_index(fullname, index, options)
          end
        end
      end

      def teardown(klass)
        fullname = self.fullname(klass)
        return if !self.exists?(fullname)
        self.connection.drop_table(fullname)
      end

      def tables(klass)
        self.connection.select_all("SHOW tables LIKE '%_#{self.suffix(klass)}'")
                       .map{|r| r.first.last.gsub(self.suffix_regex(klass),'')}
      end

      #
      # Given the input tablename, returns true if it exists in the database.
      #
      # @param tablename [String] tablename to check existence for
      #
      # @return [Boolean] true if the input tablename exists
      #
      def exists?(tablename)
        result = self.connection.execute("SHOW tables LIKE '#{tablename}'")
        result.count == 1
      end

      #
      # @return [*::DynamicSchema] schema module
      #
      def schema(klass)
        klass.const_get('DynamicSchema')
      end

      #
      # @return [String] current tablename of the dynamic model
      #
      def tablename(klass)
        klass.instance_variable_get(:@tablename)
      end

      #
      # @return [String] database tablename suffix for the given model
      #
      def suffix(klass)
        klass.name.underscore.pluralize
      end

      #
      # @return [Regexp] identifying regex of given dynamic model's tablename
      #
      def suffix_regex(klass)
        Regexp.new("_#{klass.name.underscore.pluralize}$")
      end

      #
      # @return [String] name of the currently select dynamic table
      #
      def fullname(klass)
        "#{self.tablename(klass)}_#{self.suffix(klass)}"
      end

      #
      # @return [ActiveRecord::ConnectionAdapters::*] database connection
      #   adapter
      #
      def connection
        ActiveRecord::Base.connection
      end

    end
  end
end
