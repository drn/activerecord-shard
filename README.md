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

### License

(The MIT License)

Copyright © 2014 Darren Cheng

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
