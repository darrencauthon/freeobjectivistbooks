class Geocoder
  class << self
    def base_url
      "http://maps.googleapis.com/maps/api/geocode"
    end

    def client
      @@client ||= RestClient::Resource.new "#{base_url}/json" do |response, request, result, &block|
        case response.code
        when 200..299 then JSON.parse response
        else response.return! request, result, &block
        end
      end
    end

    def geocode(address)
      Rails.logger.info "Geocoding '#{address}'"
      response = client.get params: {address: address, sensor: false}
      raise "Geocode response status: #{response['status']}" if response['status'] != "OK"
      response['results']
    end
  end
end
