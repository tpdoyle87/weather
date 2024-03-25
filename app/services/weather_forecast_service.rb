# frozen_string_literal: true

# Service to fetch weather forecasts
class WeatherForecastService
  def self.fetch_forecast(street: nil, city: nil, state: nil, zip: nil)
    cache_key = "weather_forecast_#{[street, city, state, zip].compact.join('_')}"
    cached = Rails.cache.read(cache_key)

    if cached
      cached.merge!(cacheHit: true)
    else
      latitude, longitude = GeocodingService.fetch_coordinates(street: street, city: city, state: state, zip: zip)
      forecast_data = full_forecast_fetch(latitude, longitude)
      forecast_data_with_hit_info = forecast_data.merge(cacheHit: false)

      Rails.cache.write(cache_key, forecast_data_with_hit_info, expires_in: 30.minutes)
      forecast_data_with_hit_info
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
