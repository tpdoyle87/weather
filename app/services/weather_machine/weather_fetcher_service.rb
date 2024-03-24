# frozen_string_literal: true

module WeatherMachine
  # Service to fetch weather data and format the high and low temperatures for the next 7 days
  # along with returning the current temperature.
  class WeatherFetcherService
    DAYS_OF_THE_WEEK = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze
    attr_accessor :forecast
    attr_reader :latitude, :longitude

    def initialize(params)
      @latitude = params[:latitude]
      @longitude = params[:longitude]
      @forecast = {
        current_temperature: nil,
        next_seven_days: []
      }
    end

    def call
      # returns an object containing the endpoints for the nearby weather stations and forecast.
      local_grid = fetch_grid
      # returns the forecast data for the next 7 days.
      forecast_data = fetch_seven_day_forecast(local_grid)
      # builds the forecast object with the current temperature and the high and low temperatures for the next 7 days.
      build_forecast(forecast_data)
      forecast
    end

    def build_forecast(forecast_data)
      # Assume the first period has the current temperature
      current_period = forecast_data['properties']['periods'].first
      forecast[:current_temperature] = {
        temperature: current_period['temperature'],
        unit: current_period['temperatureUnit']
      }
      not_current_day_index = first_daily_forecast_index(forecast_data)
      build_current_day_forecast(forecast_data, not_current_day_index, forecast)
      forecast_for_week(forecast_data, not_current_day_index, forecast)
    end

    def first_daily_forecast_index(forecast_data)
      forecast_data['properties']['periods'].index do |period|
        DAYS_OF_THE_WEEK.any? { |day| period['name'].start_with?(day) }
      end
    end

    def build_current_day_forecast(forecast_data, end_index, forecast)
      return unless end_index

      high_period = forecast_data['properties']['periods'][0]
      low_period = forecast_data['properties']['periods'][0]

      high_period, low_period = find_high_low_temp_period(end_index, forecast_data, high_period, low_period)
      build_current_day(forecast, high_period, low_period)
    end

    def forecast_for_week(forecast_data, start_index, forecast)
      return unless start_index

      forecast_data['properties']['periods'][start_index..].each_with_index do |period, index|
        if index.even?
          forecast[:next_seven_days] << build_high_temp(period)
        else
          forecast[:next_seven_days].last.merge!(build_low_temp(period))
        end

        break if forecast[:next_seven_days].size == 7
      end
    end

    private

    def find_high_low_temp_period(end_index, forecast_data, high_period, low_period)
      forecast_data['properties']['periods'][0..end_index].each_with_index do |period, index|
        if period['temperature'] > high_period['temperature']
          high_period = forecast_data['properties']['periods'][index]
        end
        low_period = forecast_data['properties']['periods'][index] if period['temperature'] < low_period['temperature']
      end
      [high_period, low_period]
    end

    def build_current_day(forecast, high_period, low_period)
      forecast[:next_seven_days] << build_high_temp(high_period)
      forecast[:next_seven_days].last.merge!(build_low_temp(low_period))
    end

    def fetch_seven_day_forecast(local_grid)
      response = RestClient.get(local_grid['properties']['forecast'])
      JSON.parse(response.body)
    end

    def fetch_grid
      response = RestClient.get("https://api.weather.gov/points/#{latitude},#{longitude}")
      JSON.parse(response.body)
    end

    def build_low_temp(period)
      {
        lowTemperature: period['temperature'],
        lowTemperatureUnit: period['temperatureUnit']
      }
    end

    def build_high_temp(period)
      {
        day: period['name'],
        highTemperature: period['temperature'],
        highTemperatureUnit: period['temperatureUnit']
      }
    end
  end
end
