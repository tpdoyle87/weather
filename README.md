# Weather Forecast App

- This application relies on api.weather.gov to retrieve weather information.  

## Overview
This Rails application provides real-time weather forecasts based on user-submitted addresses. Utilizing the GeocodingService to convert addresses into geographic coordinates and the WeatherForecastService to fetch weather data, it offers a streamlined way to access weather information.

## Features
- **Geocoding**: Converts street addresses into latitude and longitude.
- **Weather Forecasting**: Retrieves weather forecasts using geocoded coordinates.
- **Caching**: Improves response times and reduces external API calls by caching weather data.

## Pre-requisites
- **Ruby**: 3.2.2
- **Rails**: 7.1.2
- **Bundler**: 2.4.10

## Setup
1. Clone the repository.
```git clone git@github.com:tpdoyle87/weather.git ```
2. install dependencies.
```bundle install```
3. Configure environment variables.  
```cp .env.sample .env```  
   Set GOOGLE_API_KEY to your Google Geocoding API key.
4. Ensure caching is enabled.
```rails dev:cache```

## Running the application
1. Start the server.
```rails server```
2. Access the application in your browser.
```http://localhost:3000```

## Usage
### Fetching a Forecast
- endpoint: `/forecasts`
- parameters: `street`, `city`, `state`, `zip`
- Example request:  
```GET /forecasts?street=1600+Amphitheatre+Parkway&city=Mountain+View&state=CA&zip=94043```
  - If some fields are missing the geocoding will make its best guess but this is limited to weather 
  available from weather.gov
### Response
```
{
  "currentTemperature": {
    "temperature": 59,
    "unit": "F"
  },
  "nextSevenDays": [
    {
      "day": "Today",
      "highTemperature": 62,
      "highTemperatureUnit": "F",
      "lowTemperature": 48,
      "lowTemperatureUnit": "F"
    },...
    ]}
```

## Development
### Running Tests
```bundle exec rspec```
### Linting
```bundle exec rubocop```

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
