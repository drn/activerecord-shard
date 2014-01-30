require_relative 'spec_helper.rb'

describe 'ActiveRecord::Dynamic Integration' do

  let(:core){ ActiveRecord::Dynamic::Core }
  let(:schema){ ActiveRecord::Dynamic::Schema }

  it 'should pass basic usage test' do
    expect{DynamicKlass.count}.to raise_error(ActiveRecord::Dynamic::UnpreparedError)
    DynamicKlass.use('sample')
    expect(DynamicKlass.count).to eq(0)
    DynamicKlass.create
    expect(DynamicKlass.count).to eq(1)
    schema.teardown(DynamicKlass)
    expect{DynamicKlass.count}.to raise_error(ActiveRecord::StatementInvalid)
  end

end
