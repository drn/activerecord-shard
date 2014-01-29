require_relative '../spec_helper.rb'

describe ActiveRecord::Dynamic do

  let(:core){ ActiveRecord::Dynamic::Core }
  let(:schema){ ActiveRecord::Dynamic::Schema }

  it 'should setup and teardown' do
    tablename = 'tablename'
    fullname = "#{tablename}_#{schema.suffix(DynamicKlass)}"
    expect(schema.exists?(fullname)).to eq(false)
    DynamicKlass.use(tablename)
    expect(schema.exists?(fullname)).to eq(true)
    schema.teardown(DynamicKlass)
    expect(schema.exists?(fullname)).to eq(false)
  end

end
