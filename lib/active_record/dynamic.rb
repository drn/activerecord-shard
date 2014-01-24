module ActiveRecord::Dynamic
  extend ActiveSupport::Concern

  class UnpreparedError < ::StandardError; end
  class InvalidUsageError < ::StandardError; end

  class Core

    #
    # Given an input class, ensures that there exists a nested class which
    # subclasses ActiveRecord::Base.
    #
    # eg. for klass === Klass, existance is ensured for:
    #   Klass::Dynamic < ActiveRecord::Base
    #
    # @param klass [Class] klass to create Dynamic subclass for
    #
    def self.constantize(klass)
      unless (!!klass.const_get('Dynamic') rescue false)
        klass.const_set('Dynamic',Class.new(ActiveRecord::Base))
      end
    end

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
    def self.suffix(klass)
      klass.name.underscore.pluralize
    end

    #
    # Given the input tablename, returns true if it exists in the database.
    #
    # @param tablename [String] tablename to check existance for
    #
    # @return [Boolean] true if the input tablename exists
    #
    def self.exists?(tablename)
      ActiveRecord::Base.connection.execute(
        "SHOW tables LIKE '#{tablename}'"
      ).count == 1
    end

  end

  module ClassMethods

    #
    # @param tablename [String] name of table
    #
    # @return [Class] Transaction class
    #
    def use(tablename)
      ActiveRecord::Dynamic::Core.constantize(self)
      if tablename.blank?
        raise ActiveRecord::Dynamic::InvalidUsageError.new(
          "#{self} can not use an empty tablename."
        )
      end

      @tablename = "#{tablename}_#{ActiveRecord::Dynamic::Core.suffix(self)}"
      @backed = self.const_get('Dynamic')
      @backed.table_name = @tablename
      self.setup
      return self
    end

    #
    #
    #
    def tables
      suffix = ActiveRecord::Dynamic::Core.suffix(self)
      ActiveRecord::Base.connection
                        .select_all("SHOW tables LIKE '%_#{suffix}'")
                        .map{|r| r.first.last}
    end

    #
    # @yield
    #
    def each
      suffix = "_#{ActiveRecord::Dynamic::Core.suffix(self)}^"
      self.tables.each do |table|
        yield(self.use(table.gsub(Regexp.new(suffix),'')))
      end
    end

    protected

      #
      # @param sym [Symbol] method name
      # @param args [Array] passed in arguments
      #
      def method_missing(sym, *args, &block)
        if @tablename.blank?
          raise ActiveRecord::Dynamic::UnpreparedError.new(
            "Table name must be established via #{self}.use(..) before"\
            " this method can be called."
          )
        end
        self.const_get('Dynamic').send(sym, *args, &block)
      end

      def setup
        return if ActiveRecord::Dynamic::Core.exists?(@tablename) ||
                  @tablename.blank?
        connection = ActiveRecord::Base.connection
        connection.create_table(@tablename) do |table|
          self.const_get('DynamicSchema').setup(table)
          table.timestamps
        end
        self.const_get('DynamicSchema').send(:indexes).each do |index|
          case index
          when Symbol
            connection.add_index(@tablename, index)
          when Hash
            index_config = index.first
            index = index_config[0]
            options = index_config[1]
            connection.add_index(@tablename, index, options)
          end
        end
      end

      def teardown
        return if !ActiveRecord::Dynamic::Core.exists?(@tablename) ||
                  @tablename.blank?
        ActiveRecord::Base.connection.drop_table(@tablename)
      end

      def teardown_all
        connection = ActiveRecord::Base.connection
        self.tables.each{|table| connection.drop_table(table)}
      end

  end

end
