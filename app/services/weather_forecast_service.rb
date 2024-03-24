# frozen_string_literal: true

# Service to fetch weather forecasts
class WeatherForecastService
  def self.fetch_forecast(street: nil, city: nil, state: nil, zip: nil)
    cache_key = "weather_forecast_#{street}_#{city}_#{state}_#{zip}"

    Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      latitude, longitude = GeocodingService.fetch_coordinates(street:, city:, state:, zip:)

      full_forecast_fetch(latitude, longitude)
    end
  end

  def self.full_forecast_fetch(latitude, longitude)
    if latitude.blank? || longitude.blank?
      { error: 'Latitude and longitude could not be determined from the provided address.' }
    else
      begin
        service = WeatherMachine::WeatherFetcherService.new(latitude:, longitude:)
        service.call
      rescue StandardError => e
        { error: e.message }
      end
    end
  end
end
