# frozen_string_literal: true

# Controller to return forecasts
class ForecastsController < ApplicationController
  def show
    forecast = WeatherForecastService.fetch_forecast(**forecast_params)
    if forecast[:error]
      status = determine_status(forecast[:error])
      render json: { error: forecast[:error] }, status:
    else
      render json: forecast, status: :ok
    end
  end

  private

  def forecast_params
    params.permit(:street, :city, :state, :zip).to_h.symbolize_keys
  end

  def determine_status(error_message)
    if error_message == 'Latitude and longitude could not be determined from the provided address.'
      :bad_request
    else
      :internal_server_error
    end
  end
end
