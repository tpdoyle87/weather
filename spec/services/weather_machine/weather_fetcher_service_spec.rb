# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherMachine::WeatherFetcherService, type: :service do
  describe '#call' do
    let(:latitude) { '39.7456' }
    let(:longitude) { '-97.0892' }
    let(:service) { described_class.new(latitude:, longitude:) }

    before do
      # Stub the request for the weather station data
      stub_request(:get, "https://api.weather.gov/points/#{latitude},#{longitude}")
        .to_return(status: 200, body: Rails.root.join('spec/fixtures/fetch_grid_data.json').read)

      # Stub the request for the actual forecast data
      stub_request(:get, 'https://api.weather.gov/gridpoints/TOP/32,81/forecast')
        .to_return(status: 200, body: Rails.root.join('spec/fixtures/fetch_forecast_data.json').read)
    end

    it 'correctly fetches and processes the weather forecast' do
      service.call

      expect(service.forecast[:current_temperature]).to eq({ temperature: 56, unit: 'F' })
    end

    it 'correctly fetches and processes the weather forecast for the next 7 days' do
      service.call

      expect(service.forecast[:next_seven_days].size).to eq(7)
    end
  end
end
