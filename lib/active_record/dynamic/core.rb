module ActiveRecord::Dynamic
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
end
