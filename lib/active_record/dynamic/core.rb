module ActiveRecord::Dynamic
  class Core
    class << self

      def establish_delegate(klass, tablename)
        klass.instance_variable_set(:@tablename, tablename)
        fullname = ActiveRecord::Dynamic::Schema.fullname(klass)
        klass.const_get('DynamicRecord').table_name = fullname
      end

      def each(klass)
        ActiveRecord::Dynamic::Schema.tables(klass).each do |tablename|
          self.establish_delegate(klass, tablename)
          yield
        end
      end

    end
  end
end
