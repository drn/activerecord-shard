require_relative '../spec_helper.rb'

describe ActiveRecord::Dynamic do

  let(:core){ ActiveRecord::Dynamic::Core }
  let(:schema){ ActiveRecord::Dynamic::Schema }

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

  before(:each) do
    core.each(DynamicKlass) do
      schema.teardown(DynamicKlass)
    end
  end

  it 'should setup and teardown' do
    tablename = 'tablename'
    fullname = "#{tablename}_#{schema.suffix(DynamicKlass)}"
    expect(schema.exists?(fullname)).to eq(false)
    DynamicKlass.use(tablename)
    expect(schema.exists?(fullname)).to eq(true)
    schema.teardown(DynamicKlass)
    expect(schema.exists?(fullname)).to eq(false)
  end

  after(:all) do
    Object.send(:remove_const, :DynamicKlass)
  end

end
