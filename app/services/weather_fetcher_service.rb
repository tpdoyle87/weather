module WeatherMachine
  class WeatherFetcherService
    def initialize(params)
      @latitude = params[:street]
      @longitude = params[:city]
    end

    def call
      response = RestClient.get("https://api.weather.gov/points/#{@latitude},#{@longitude}")
      weather = JSON.parse(response.body)
    end
  end
end