module ActiveRecord::Dynamic
  class Core
    class << self

      #
      # Given the input class, returns a dynamic tablename suffix.
      #
      # eg. for klass === Klass
      #   class Klass::Dynamic < ActiveRecord::Base
      #     self.table_name = '..._klasses'
      #   end
      #   where ... is whatever tablename is specified in the use method
      #
      # @param klass [Class] klass to return suffix for
      #
      # @return [String] dynamic klass table name suffix
      #
      def suffix(klass)
        klass.name.underscore.pluralize
      end

      def suffix_regex(klass)
        Regexp.new("_#{self.suffix}$")
      end

      def establish_delegate(klass, tablename)
        full_tablename = "#{tablename}_#{self.suffix(klass)}"
        klass.instance_variable_set(:@tablename, full_tablename)
        dynamic_klass = klass.const_get('Dynamic')
        dynamic_klass.table_name = full_tablename
      end

      #
      # Given the input tablename, returns true if it exists in the database.
      #
      # @param tablename [String] tablename to check existance for
      #
      # @return [Boolean] true if the input tablename exists
      #
      def exists?(tablename)
        self.connection.execute("SHOW tables LIKE '#{tablename}'").count == 1
      end

      #
      def tables(klass)
        self.connection.select_all("SHOW tables LIKE '%_#{self.suffix(klass)}'")
                       .map{|r| r.first.last}
      end

      #
      #
      def each(klass)
        self.tables.each do |table|
          self.establish_delegate(klass, tablename)
          yield
        end
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
