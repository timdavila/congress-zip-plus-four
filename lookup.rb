gem 'json', '>= 1.7.0'
require "httparty"
require "csv"
require 'pp'
require "json"
require "geocoder"

# at startup set API key
sunlight_api_key = ""

# Geocoder.configure(
#   # geocoding service (see below for supported options):
#   :lookup => :bing,
#   :api_key => "AteXbpL6dqP0I-BfEINSjasTpBsItQHxzlPC3dzrnze94BwlgctEZhsj9E0XRopr"
# )

puts Geocoder::Result::Google.instance_methods

contents = CSV.read('./2 - address+zip4.csv', :encoding => 'windows-1251:utf-8')
contents.each() do |row|
  
  entry={}
  entry["street_address"], entry["zip"], entry["plus_four"] = row[0], row[1], row[2]
  # puts "#{entry["street_address"]}, #{entry["zip"]}"                                                                #DEBUG
  rg_result = Geocoder.search("#{entry["street_address"]}, #{entry["zip"]}").first
  #puts rg_result.inspect                                                                                                        #DEBUG
  if (!rg_result)  then puts "error: no response from geocoder"; next end

  # Add a warning if zip returned from Google is different to our CSV zip.
  if (rg_result.postal_code != entry["zip"]) then entry["warning"] ="Zip has changed" end
  # Save lat/lng
  entry["lat"] = rg_result.latitude
  entry["lon"] = rg_result.longitude
  entry["city"] = rg_result.city
  entry["street_address"] = rg_result.street_address
  entry["state"] = rg_result.state_code

  district_result = {}

  # Query Sunlight and check and save state and district number:
  district_query_url = "http://congress.api.sunlightfoundation.com/districts/locate?apikey=#{sunlight_api_key}&latitude=#{entry["lat"]}&longitude=#{entry["lon"]}"
  district_result = HTTParty.get(district_query_url).parsed_response

  if (district_result["results"] != [])
    entry["district_state"] = district_result["results"][0]["state"].to_s
    entry["district_number"] = district_result["results"][0]["district"].to_s
  else
    entry["district_state"] = entry["district_number"] = "not found"
  end

  # Query Sunlight and check and save bio_id and house Rep. Name
  rep_query_url = "http://congress.api.sunlightfoundation.com/legislators/locate?apikey=#{sunlight_api_key}&latitude=#{entry["lat"]}&longitude=#{entry["lon"]}&chamber=house"
  rep_result = HTTParty.get(rep_query_url).parsed_response

  rep_result["results"].each do |rep|
    if (rep["chamber"]=="house")
      entry["rep_name"] = "#{rep["first_name"].to_s} #{rep["last_name"].to_s}"
      entry["bio_id"] = rep["bioguide_id"].to_s
    end
  end

  puts "#{entry["street_address"]},#{entry["city"]},#{entry["state"]},#{entry["zip"]},#{entry["plus_four"]},#{entry["district_state"]},#{entry["district_number"]},#{entry["rep_name"]},#{entry["bio_id"]}"

 end
