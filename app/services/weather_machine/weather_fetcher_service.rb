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
      response = RestClient.get("https://api.weather.gov/points/#{latitude},#{longitude}")
      local_grid = JSON.parse(response.body)
      forecast = RestClient.get(local_grid['properties']['forecast'])
      forecast_data = JSON.parse(forecast.body)
      build_forecast(forecast_data)
    end

    def build_forecast(forecast_data)
      # Assume the first period has the current temperature
      current_period = weather_data[:properties][:periods].first
      forecast[:currentTemperature] = {
        temperature: current_period[:temperature],
        unit: current_period[:temperatureUnit]
      }
      first_daily_forecast_index(forecast_data)
    end

    def first_daily_forecast_index(forecast_data)
      forecast_data[:properties][:periods].index do |period|
        DAYS_OF_THE_WEEK.any? { |day| period[:name].start_with?(day) }
      end
    end

    def forecast_for_week(forecast_data, start_index, forecast)
      return unless start_index

      forecast_data[:properties][:periods][start_index..].each_with_index do |period, index|
        if index.even?
          forecast[:nextSevenDays] << build_high_temp(period)
        else
          forecast[:nextSevenDays].last.merge!(build_low_temp(period))
        end

        break if forecast[:nextSevenDays].size == 7
      end
    end

    private

    def build_low_temp(period)
      {
        lowTemperature: period[:temperature],
        lowTemperatureUnit: period[:temperatureUnit]
      }
    end

    def build_high_temp(period)
      {
        day: period[:name],
        highTemperature: period[:temperature],
        highTemperatureUnit: period[:temperatureUnit]
      }
    end
  end
end
