require_relative '../../spec_helper.rb'

describe ActiveRecord::Dynamic::Core do

  let(:core){ ActiveRecord::Dynamic::Core }
  let(:schema){ ActiveRecord::Dynamic::Schema }

  before(:each) do
    class DynamicKlass
      include ActiveRecord::Dynamic
      class DynamicRecord < ActiveRecord::Base; end
      module DynamicSchema
        class << self
          def setup(table); end
          def indexes; [] end
        end
      end
    end
  end

  context :establish_delegate do
    it 'should establish delegate' do
      tablename = 'tablename'
      fullname = 'fullname'
      klass = DynamicKlass
      dynamic_klass = DynamicKlass::DynamicRecord
      allow(schema).to receive(:fullname).and_return(fullname)

      expect(klass.instance_variable_get(:@tablename)).to be(nil)
      expect(dynamic_klass.table_name).to_not eq(fullname)

      core.establish_delegate(klass, tablename)
      expect(klass.instance_variable_get(:@tablename)).to eq(tablename)
      expect(dynamic_klass.table_name).to eq(fullname)
    end
  end

  context :each do
    it 'should iterate properly' do
      tablenames = ['one','two','three']
      allow(schema).to receive(:tables).and_return(tablenames)
      i = 0
      core.each(DynamicKlass) do |klass|
        expect(
          DynamicKlass::DynamicRecord.table_name
        ).to eq(
          tablenames[i]+"_dynamic_klasses"
        )
        i += 1
      end
    end
  end

  after(:each) do
    Object.send(:remove_const, :DynamicKlass)
  end

end
