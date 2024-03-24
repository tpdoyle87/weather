# frozen_string_literal: true

Geocoder.configure(
  lookup: :google,
  timeout: 5,
  api_key: ENV.fetch('GOOGLE_API_KEY', nil),
  units: :mi,
  use_https: true
)
