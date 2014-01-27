module ActiveRecord::Dynamic
  class Validator
    class << self

      def validate_configuration!(klass)
        unless (!!klass.const_get('Dynamic') rescue false)
          raise ActiveRecord::Dynamic::InvalidUsageError.new(
            "#{klass}::Dynamic < ActiveRecord::Base is expected to exist"
          )
        end
        unless (!!klass.const_get('DynamicSchema') rescue false)
          raise ActiveRecord::Dynamic::InvalidUsageError.new(
            "#{klass}::DynamicSchema < ActiveRecord::Base is expected to exist"
          )
        end
      end

      def validate_setup!(klass)
        tablename = klass.instance_variable_get(:tablename)
        if tablename.blank?
          raise ActiveRecord::Dynamic::UnpreparedError.new(
            "Table name must be established via #{klass}.use(..) before"\
            " this method can be called."
          )
        end
      end

      def validate_tablename!(tablename)
        if tablename.blank?
          raise ActiveRecord::Dynamic::InvalidUsageError.new(
            "Tablename is expected to be non-empty"
          )
        end
      end

    end
  end
end
