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
        currentTemperature: nil,
        nextSevenDays: []
      }
    end

    def call
      # returns an object containing the endpoints for the nearby weather stations and forecast.
      local_grid = fetch_data("https://api.weather.gov/points/#{latitude},#{longitude}")
      # returns the forecast data for the next 7 days.
      forecast_data = fetch_data(local_grid['properties']['forecast'])
      # builds the forecast object with the current temperature and the high and low temperatures for the next 7 days.
      build_forecast(forecast_data)
      forecast
    end

    def build_forecast(forecast_data)
      current_period = forecast_data['properties']['periods'].first
      forecast[:currentTemperature] = {
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
          forecast[:nextSevenDays] << build_high_temp(period)
        else
          forecast[:nextSevenDays].last.merge!(build_low_temp(period))
        end

        break if forecast[:nextSevenDays].size == 7
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
      forecast[:nextSevenDays] << build_high_temp(high_period, 'Today')
      forecast[:nextSevenDays].last.merge!(build_low_temp(low_period))
    end

    def fetch_data(url)
      response = RestClient.get(url)
      JSON.parse(response.body)
    rescue RestClient::NotFound => e
      raise StandardError, "Couldn't find weather data. Error: #{e.message}"
    rescue RestClient::InternalServerError => e
      raise StandardError, "Something went wrong when requesting the weather details. Error: #{e.message}"
    rescue StandardError => e
      raise StandardError, "An unexpected error occurred: #{e.message}"
    end

    def build_low_temp(period)
      {
        lowTemperature: period['temperature'],
        lowTemperatureUnit: period['temperatureUnit']
      }
    end

    def build_high_temp(period, name = nil)
      {
        day: name.presence || period['name'],
        highTemperature: period['temperature'],
        highTemperatureUnit: period['temperatureUnit']
      }
    end
  end
end
