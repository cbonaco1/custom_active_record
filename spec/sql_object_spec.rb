require 'sql_object'
require 'db_connection'
require 'securerandom'

describe SQLObject do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  context 'before ::finalize!' do
    before(:each) do
      class Band < SQLObject
      end
    end

    after(:each) do
      Object.send(:remove_const, :Band)
    end

    describe '::table_name' do
      it 'generates default name' do
        expect(Band.table_name).to eq('bands')
      end
    end

    describe '::table_name=' do
      it 'sets table name' do
        class Human < SQLObject
          self.table_name = 'humans'
        end

        expect(Human.table_name).to eq('humans')

        Object.send(:remove_const, :Human)
      end
    end

    describe '::columns' do
      it 'returns a list of all column names as symbols' do
        expect(Band.columns).to eq([:id, :name])
      end

      it 'only queries the DB once' do
        expect(DBConnection).to(
          receive(:execute2).exactly(1).times.and_call_original)
        3.times { Band.columns }
      end
    end

    describe '#attributes' do
      it 'returns @attributes hash byref' do
        band_attributes = {name: 'The Foo Fighters'}
        b = Band.new
        b.instance_variable_set('@attributes', band_attributes)

        expect(b.attributes).to equal(band_attributes)
      end

      it 'lazily initializes @attributes to an empty hash' do
        b = Band.new

        expect(b.instance_variables).not_to include(:@attributes)
        expect(b.attributes).to eq({})
        expect(b.instance_variables).to include(:@attributes)
      end
    end
  end

  context 'after ::finalize!' do
    before(:all) do
      class Band < SQLObject
        self.finalize!
      end
    end

    after(:all) do
      Object.send(:remove_const, :Band)
    end

    describe '::finalize!' do
      it 'creates getter methods for each column' do
        b = Band.new
        expect(b.respond_to? :something).to be false
        expect(b.respond_to? :name).to be true
        expect(b.respond_to? :id).to be true
        expect(b.respond_to? :other_thing).to be false
      end

      it 'creates setter methods for each column' do
        b = Band.new
        b.name = "Dave Matthews Band"
        b.id = 209
        expect(b.name).to eq 'Dave Matthews Band'
        expect(b.id).to eq 209
      end

      it 'created getter methods read from attributes hash' do
        b = Band.new
        b.instance_variable_set(:@attributes, {name: "Dave Matthews Band"})
        expect(b.name).to eq 'Dave Matthews Band'
      end

      it 'created setter methods use attributes hash to store data' do
        b = Band.new
        b.name = "OAR"

        expect(b.instance_variables).to include(:@attributes)
        expect(b.instance_variables).not_to include(:@name)
        expect(b.attributes[:name]).to eq 'OAR'
      end
    end

    describe '#initialize' do
      it 'calls appropriate setter method for each item in params' do
        b = Band.allocate

        expect(b).to receive(:name=).with('The Eagles')
        expect(b).to receive(:id=).with(100)

        b.send(:initialize, {name: 'The Eagles', id: 100})
      end

      it 'throws an error when given an unknown attribute' do
        expect do
          Band.new(cat: 'Sennacy')
        end.to raise_error "unknown attribute 'cat'"
      end
    end

    describe '::all, ::parse_all' do
      it '::all returns all the rows' do
        bands = Band.all
        expect(bands.count).to eq(4)
      end

      it '::parse_all turns an array of hashes into objects' do
        hashes = [
          { name: 'The Foo Figthers' },
          { name: 'Chicago' }
        ]

        bands = Band.parse_all(hashes)
        expect(bands.length).to eq(2)
        hashes.each_index do |i|
          expect(bands[i].name).to eq(hashes[i][:name])
        end
      end

      it '::all returns a list of objects, not hashes' do
        bands = Band.all
        bands.each { |band| expect(band).to be_instance_of(Band) }
      end
    end

    describe '::find' do
      it 'fetches single objects by id' do
        b = Band.find(1)

        expect(b).to be_instance_of(Band)
        expect(b.id).to eq(1)
      end

      it 'returns nil if no object has the given id' do
        expect(Band.find(123)).to be_nil
      end
    end

    describe '#attribute_values' do
      it 'returns array of values' do
        band = Band.new(id: 123, name: 'band1')

        expect(band.attribute_values).to eq([123, 'band1'])
      end
    end

    describe '#insert' do
      let(:band) { Band.new(name: 'Jimmy Hendrix') }

      before(:each) { band.insert }

      it 'inserts a new record' do
        expect(Band.all.count).to eq(5)
      end

      it 'sets the id once the new record is saved' do
        expect(band.id).to eq(DBConnection.last_insert_row_id)
      end

      it 'creates a new record with the correct values' do
        # pull the band again
        band2 = Band.find(band.id)

        expect(band2.name).to eq('Jimmy Hendrix')
      end
    end

    describe '#update' do
      it 'saves updated attributes to the DB' do
        band = Band.find(2)

        band.name = "The Ramones"
        band.update

        # pull the band again
        band = Band.find(2)
        expect(band.name).to eq('The Ramones')
      end
    end

    describe '#save' do
      it 'calls #insert when record does not exist' do
        band = Band.new
        expect(band).to receive(:insert)
        band.save
      end

      it 'calls #update when record already exists' do
        band = Band.find(1)
        expect(band).to receive(:update)
        band.save
      end
    end
  end
end
