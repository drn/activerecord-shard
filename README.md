# ActiveRecord::Dynamic

Easily interact with multiple database tables while leveraging a single
ActiveRecord::Base model.

### Disclaimer

This is in a very early alpha - use at your own risk.

### Usage

    class Car
      include ActiveRecord::Dynamic

      #
      # Define the model as you would a normal ActiveRecord::Base subclass
      #
      module Dynamic < ActiveRecord::Base
        validates :license_plate, presence: true, uniqueness: true
        validates :driver_id, presence: true
        belongs_to :driver
        ...
      end

      #
      # Define the schema to dynamically setup and teardown
      #
      module DynamicSchema
        class << self

          # set up the dynamic table's schema
          def setup(table)
            table.string :license_plate
            table.integer :driver_id
          end

          # optionally add indexes
          def indexes
            [ :driver_id ]
          end
        end
      end
    end

    class Manufacturer < ActiveRecord::Base
      def cars; Car.use(self.name) end
    end

    manufacturer = Manufacturer.new(name: 'Subaru')
    puts manufacturer.cars.count
    manufacturer.cars.create!(license_plate: 'ABCD-1234')
    puts manufacturer.cars.count

    manufacturer = Manufacturer.new(name: 'Toyota')
    puts manufacturer.cars.count
    manufacturer.cars.create!(license_plate: 'ABCD-1234')
    puts manufacturer.cars.count
    Manufacturer.send(:teardown)

    Manufacturer.use('Subaru').send(:teardown)
