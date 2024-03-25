# frozen_string_literal: true

# app/services/geocoding_service.rb
class GeocodingService
  def self.fetch_coordinates(street: nil, city: nil, state: nil, zip: nil)
    address = [street, city, state, zip].compact.join(', ')
    return if address.empty?

    Geocoder.coordinates(address)
  end
end
