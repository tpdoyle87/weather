# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GeocodingService do
  describe '.fetch_coordinates' do
    context 'when full address details are provided' do
      it 'returns the coordinates' do
        allow(Geocoder).to receive(:coordinates).with('123 Main St, Anytown, Anystate, 12345').and_return([45.0, -90.0])

        result = described_class.fetch_coordinates(street: '123 Main St', city: 'Anytown', state: 'Anystate',
                                                   zip: '12345')

        expect(result).to eq([45.0, -90.0])
      end
    end

    context 'when partial address details are provided' do
      it 'returns the coordinates for just city and state' do
        allow(Geocoder).to receive(:coordinates).with('Anytown, Anystate').and_return([45.0, -90.0])

        result = described_class.fetch_coordinates(city: 'Anytown', state: 'Anystate')

        expect(result).to eq([45.0, -90.0])
      end
    end

    context 'when no address details are provided' do
      it 'returns nil' do
        result = described_class.fetch_coordinates

        expect(result).to be_nil
      end
    end
  end
end
