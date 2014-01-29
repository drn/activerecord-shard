require 'pathname'
test_dir = Pathname.new(File.dirname(__FILE__))

# external dependencies
require "active_record"
# internal dependencies
require 'active_record/dynamic'
# test dependencies
require 'pry-remote'

# configure ActiveRecord for testing
ENV["RAILS_ENV"] = "test"
adapter = ENV["DATABASE"] || "mysql2"
ActiveRecord::Base.logger = Logger.new("log/test.log")
ActiveRecord::Base.logger.level = Logger::DEBUG
ActiveRecord::Base.configurations["test"] = YAML.load_file(test_dir.join("database.yml"))[adapter]
ActiveRecord::Base.establish_connection "test"

RSpec.configure do |config|
  # Limit the spec run to only specs with the focus metadata. If no specs have
  # the filtering metadata and `run_all_when_everything_filtered = true` then
  # all specs will run.
  #config.filter_run :focus

  # Run all specs when none match the provided filter. This works well in
  # conjunction with `config.filter_run :focus`, as it will run the entire
  # suite when no specs have `:filter` metadata.
  #config.run_all_when_everything_filtered = true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  #config.order = 'random'

  config.before(:each) do
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

  config.after(:each) do
    Object.send(:remove_const, :DynamicKlass)
  end

end


