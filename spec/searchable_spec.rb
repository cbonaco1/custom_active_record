require 'sql_object'

describe 'Searchable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Band < SQLObject
      finalize!
    end

    class Track < SQLObject
      finalize!
    end
  end

  it '#where searches with single criterion' do
    bands = Band.where(name: 'The Black Keys')
    band = bands.first

    expect(bands.length).to eq(1)
    expect(band.name).to eq('The Black Keys')
  end

  it '#where can return multiple objects' do
    tracks = Track.where(album_id: 2)
    expect(tracks.length).to eq(2)
  end

  it '#where searches with multiple criteria' do
    tracks = Track.where(name: 'Tighten Up', album_id: 2)
    expect(tracks.length).to eq(1)

    track = tracks[0]
    expect(track.name).to eq('Tighten Up')
    expect(track.album_id).to eq(2)
  end

  it '#where returns [] if nothing matches the criteria' do
    expect(Track.where(name: 'Blah blah blah')).to be_empty
  end
end
