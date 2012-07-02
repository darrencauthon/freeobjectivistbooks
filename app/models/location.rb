class Location < ActiveRecord::Base
  serialize :geocoder_results

  after_create :geocode!

  def first_geocoder_result
    @result ||= geocoder_results[0] if geocoder_results && !geocoder_results.empty?
  end

  def geometry
    @geometry ||= first_geocoder_result['geometry'] if first_geocoder_result
  end

  def location
    @location ||= geometry['location'] if geometry
  end

  def lat
    @lat ||= location['lat'] if location
  end

  def lon
    @lon ||= location['lng'] if location
  end

  def types
    @types ||= first_geocoder_result['types'] if first_geocoder_result
  end

  def locality?
    types.include? "locality"
  end

  def geocode!
    self.geocoder_results = Geocoder.geocode name
    save!
  end
  handle_asynchronously :geocode!
end
