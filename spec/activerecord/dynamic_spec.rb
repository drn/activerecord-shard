require_relative '../spec_helper.rb'

describe ActiveRecord::Dynamic do

  before(:all) do
    DynamicKlass = Class.new do
      include ActiveRecord::Dynamic
      class Dynamic < ActiveRecord::Base

      end
      module DynamicSchema
        class << self
          def setup(table); end
          def indexes; [] end
        end
      end
    end
  end

  it 'should work' do
    DynamicKlass.use('table1')
  end

end
