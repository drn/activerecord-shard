Dir[File.dirname(__FILE__) + '/dynamic/*.rb'].each{|file| require file }

module ActiveRecord::Dynamic
  extend ActiveSupport::Concern

  module ClassMethods

    #
    # @param tablename [String] name of table
    #
    # @return [Class] Transaction class
    #
    def use(tablename)
      ActiveRecord::Dynamic::Validator.validate_configuration!(self)
      ActiveRecord::Dynamic::Validator.validate_tablename!(self)
      ActiveRecord::Dynamic::Core.establish_delegate(self, tablename)
      ActiveRecord::Dynamic::Schema.setup(self)
      return self
    end

    #
    #
    #
    def tables
      ActiveRecord::Dynamic::Core.tables(self)
    end

    #
    # @yield
    #
    def each
      ActiveRecord::Dynamic::Core.each(self, &block)
    end

    protected

      #
      # Delegates all missing methods to the Dynamic class
      #
      # @param sym [Symbol] method name
      # @param args [Array] passed in arguments
      #
      def method_missing(sym, *args, &block)
        ActiveRecord::Dynamic::Validator.validate_setup!(self)
        self.const_get('Dynamic').send(sym, *args, &block)
      end

  end
end
