# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherForecastService do
  describe '.fetch_forecast' do
    let(:street) { '123 Main St' }
    let(:city) { 'Anytown' }
    let(:state) { 'Anystate' }
    let(:zip) { '12345' }
    let(:cache_key) { "weather_forecast_#{street}_#{city}_#{state}_#{zip}" }
    let(:coordinates) { ['40.7128', '-74.0060'] } # Example coordinates

    before do
      Rails.cache.clear
    end

    context 'when the address cannot be geocoded' do
      before do
        allow(GeocodingService).to receive(:fetch_coordinates).and_return([nil, nil])
      end

      it 'returns an error message' do
        result = described_class.fetch_forecast(street: 'Fake St', city: 'Nowhere', state: 'Anystate', zip: '00000')

        expect(result).to eq({ error: 'Latitude and longitude could not be determined from the provided address.' })
      end
    end

    context 'when fetching the forecast fails' do
      before do
        allow(GeocodingService).to receive(:fetch_coordinates).and_return(coordinates)
        allow_any_instance_of(WeatherMachine::WeatherFetcherService).to receive(:call).and_raise(StandardError,
                                                                                                 'Service is down')
      end

      it 'returns an error message from the failed forecast fetch' do
        result = described_class.fetch_forecast(street:, city:, state:, zip:)

        expect(result).to eq({ error: 'Service is down' })
      end
    end
  end
end
