require 'sql_object'

describe 'AssocOptions' do
  describe 'BelongsToOptions' do
    it 'provides defaults' do
      options = BelongsToOptions.new('album')

      expect(options.foreign_key).to eq(:album_id)
      expect(options.class_name).to eq('Album')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = BelongsToOptions.new('other_album',
                                     foreign_key: :album_id,
                                     class_name: 'Album',
                                     primary_key: :id
      )

      expect(options.foreign_key).to eq(:album_id)
      expect(options.class_name).to eq('Album')
      expect(options.primary_key).to eq(:id)
    end
  end

  describe 'HasManyOptions' do
    it 'provides defaults' do
      options = HasManyOptions.new('albums', 'Band')

      expect(options.foreign_key).to eq(:band_id)
      expect(options.class_name).to eq('Album')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = HasManyOptions.new('tracks', 'Album',
                                   foreign_key: :album_id,
                                   class_name: 'Track',
                                   primary_key: :id
      )

      expect(options.foreign_key).to eq(:album_id)
      expect(options.class_name).to eq('Track')
      expect(options.primary_key).to eq(:id)
    end
  end

  describe 'AssocOptions' do
    before(:all) do
      class Band < SQLObject
        self.finalize!
      end

      class Album < SQLObject
        self.finalize!
      end

      class Track < SQLObject
        self.finalize!
      end

    end

    it '#model_class returns class of associated object' do
      options = BelongsToOptions.new('album')
      expect(options.model_class).to eq(Album)

      options = HasManyOptions.new('albums', 'Band')
      expect(options.model_class).to eq(Album)
    end

    it '#table_name returns table name of associated object' do
      options = BelongsToOptions.new('band')
      expect(options.table_name).to eq('bands')

      options = HasManyOptions.new('tracks', 'Album')
      expect(options.table_name).to eq('tracks')
    end
  end
end

describe 'Associatable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Album < SQLObject
      belongs_to :band
      has_many :tracks

      finalize!
    end

    class Band < SQLObject

      has_many :albums

      finalize!
    end

    class Track < SQLObject
      belongs_to :album

      finalize!
    end
  end

  describe '#belongs_to' do
    let(:rolling_stones) { Band.find(1) }
    let(:sticky_fingers) { Album.find(1) }
    let(:track_one) { Track.find(1) }

    it 'fetches `band` from `Album` correctly' do
      expect(sticky_fingers).to respond_to(:band)
      rolling_stones = sticky_fingers.band

      expect(rolling_stones).to be_instance_of(Band)
      expect(rolling_stones.name).to eq('The Rolling Stones')
    end

    it 'fetches `album` from `Track` correctly' do
      expect(track_one).to respond_to(:album)
      stones_album = track_one.album

      expect(stones_album).to be_instance_of(Album)
      expect(stones_album.name).to eq('Sticky Fingers')
    end
  end

  describe '#has_many' do
    let(:the_beatles) { Band.find(3) }
    let(:sticky_fingers) { Album.find(1) }

    it 'fetches `albums` from `Band`' do
      expect(the_beatles).to respond_to(:albums)
      beatles_albums = the_beatles.albums

      expect(beatles_albums.length).to eq(2)

      expected_album_names = ["Revolver", "Greatest Hits"]
      2.times do |i|
        album = beatles_albums[i]

        expect(album).to be_instance_of(Album)
        expect(album.name).to eq(expected_album_names[i])
      end
    end

    it 'fetches `tracks` from `Album`' do
      expect(sticky_fingers).to respond_to(:tracks)
      tracks = sticky_fingers.tracks

      expect(tracks.length).to eq(3)
      expect(tracks[0]).to be_instance_of(Track)
      expect(tracks[0].name).to eq('Sympathy for the Devil')
    end

    it 'returns an empty array if no associated items' do
      struggling_band = Band.find(4)
      expect(struggling_band.albums).to eq([])
    end
  end

  describe '::assoc_options' do
    it 'defaults to empty hash' do
      class TempClass < SQLObject
      end

      expect(TempClass.assoc_options).to eq({})
    end

    it 'stores `belongs_to` options' do
      album_assoc_options = Album.assoc_options
      band_options = album_assoc_options[:band]

      expect(band_options).to be_instance_of(BelongsToOptions)
      expect(band_options.foreign_key).to eq(:band_id)
      expect(band_options.class_name).to eq('Band')
      expect(band_options.primary_key).to eq(:id)
    end

    it 'stores options separately for each class' do
      expect(Band.assoc_options).to have_key(:albums)
      expect(Album.assoc_options).to_not have_key(:albums)

      expect(Album.assoc_options).to have_key(:band)
      expect(Band.assoc_options).to_not have_key(:band)
    end
  end

  describe '#has_one_through' do
    before(:all) do
      class Track
        has_one_through :band, :album, :band

        self.finalize!
      end
    end

    let(:track) { Track.find(1) }

    it 'adds getter method' do
      expect(track).to respond_to(:band)
    end

    it 'fetches associated `band` for a `Track`' do
      the_stones = track.band

      expect(the_stones).to be_instance_of(Band)
      expect(the_stones.name).to eq('The Rolling Stones')
    end
  end






end
