require_relative '../../spec_helper.rb'

describe ActiveRecord::Dynamic::Core do

  let(:core){ ActiveRecord::Dynamic::Core }
  let(:schema){ ActiveRecord::Dynamic::Schema }

  before(:each) do
    DynamicKlass = Class.new do
      include ActiveRecord::Dynamic
      class Dynamic < ActiveRecord::Base; end
      module DynamicSchema
        class << self
          def setup(table); end
          def indexes; [] end
        end
      end
    end
  end

  it 'should establish delegate' do
    tablename = 'tablename'
    fullname = 'fullname'
    klass = DynamicKlass
    dynamic_klass = DynamicKlass::Dynamic
    allow(schema).to receive(:fullname).and_return(fullname)

    expect(klass.instance_variable_get(:@tablename)).to be(nil)
    expect(dynamic_klass.table_name).to_not eq(fullname)

    core.establish_delegate(klass, tablename)
    expect(klass.instance_variable_get(:@tablename)).to eq(tablename)
    expect(dynamic_klass.table_name).to eq(fullname)
  end


  after(:each) do
    Object.send(:remove_const, :DynamicKlass)
  end

end
