gem 'json', '>= 1.7.0'
require "httparty"
require "csv"
require 'pp'
require "json"
require "geocoder"

# at startup set API key
sunlight_api_key = "0268e7d928694dfe85b778415c844a66"

smarty_streets_id = "9c47fd62-1122-40b1-a08d-f307a254804f"
smarty_streets_token= "QgjQ4Mqa0llvDK53F9EsfhE2v3X6DtSWwsy2KI%2FZaRsatmrKFNYtP3IEjEah5din17Jge1ulXGgG%2FYjil%2F%2FFYw%3D%3D"


# Geocoder.configure(
#   # geocoding service (see below for supported options):
#   :lookup => :bing,
#   :api_key => "AteXbpL6dqP0I-BfEINSjasTpBsItQHxzlPC3dzrnze94BwlgctEZhsj9E0XRopr"
# )

puts Geocoder::Result::Google.instance_methods

contents = CSV.read('./address+zip4.csv', :encoding => 'windows-1251:utf-8')
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

  # puts rg_result.street_address
  # puts rg_result.postal_code


  # if (rg_result) 
  #   puts "#{rg_result.address_data["addressLine"]}" + ", " + "#{rg_result.address_data["locality"]}" + ", " + "#{rg_result.address_data["adminDistrict"]}"  + ", " + "#{rg_result.address_data["postalCode"]}"

  #   street_address = city = state = zip = ""

  #   street_address = rg_result.address_data["addressLine"].to_s
  #   city = rg_result.address_data["locality"].to_s
  #   state = rg_result.address_data["adminDistrict"].to_s
  #   zip = rg_result.address_data["postalCode"].to_s

  #   # Don't bother if there's no street address
  #   if (street_address == "") then puts "error  - no street address"; next; end

  #   url = "https://api.smartystreets.com/street-address?auth-id=#{smarty_streets_id}&auth-token=#{smarty_streets_token}&street=#{URI.encode(street_address)}&city=#{URI.encode(city)}&state=#{URI.encode(state)}&zipcode=#{URI.encode(zip)}&candidates=1"
  #   puts url.inspect
  #   geocode_result = HTTParty.get(url).parsed_response
  #   puts geocode_result.inspect

  #   if (geocode_result == [] ) then puts "error empty smartystreets response"; next; end
  #   if  !geocode_result then puts "no response from smartystreets"; next; end

  #   newzip = zip_plus_four = ""
  #   newzip = geocode_result[0]["components"]["zipcode"].to_s
  #   zip_plus_four = geocode_result[0]["components"]["plus4_code"].to_s

  #   # Add a warning if the zip code has changed after the second geocode.
  #   if ( newzip !=  zip ) then zip += "changed!" end

  #     puts "#{street_address}, #{city}, #{state}, #{zip},#{zip_plus_four}"






  # if (rg_result)
  #   street_address = (rg_result.street_number.to_s + " " + rg_result.street_address.to_s).strip;
  #   url = "https://api.smartystreets.com/street-address?auth-id=#{smarty_streets_id}&auth-token=#{smarty_streets_token}&street=#{URI.encode (rg_result.street_address.to_s)}&city=#{URI.encode(rg_result.city.to_s)}&state=#{URI.encode(rg_result.state_code.to_s)}&zipcode=#{URI.encode(rg_result.postal_code.to_s)}&candidates=1"
  #     geocode_result = HTTParty.get(url).parsed_response

  #   if (geocode_result != [] && geocode_result)

  #     if ( geocode_result[0]["components"]["zipcode"] !=  rg_result.postal_code ) 
  #       puts "Warning: the zip code changed. Something's up with the next line."
  #     end

  #     address = {}
  #     address["zip_code"] = geocode_result[0]["components"]["zipcode"]
  #     address["plus_four"] =  geocode_result[0]["components"]["plus4_code"]

  #     puts "#{rg_result.street_address},#{rg_result.city},#{rg_result.state},#{rg_result.postal_code},#{address["plus_four"]}"
  #   else
  #     puts "#{rg_result.street_address},#{rg_result.city},#{rg_result.state},#{rg_result.postal_code},FAILED"
  #   end

  # else 
  #   puts "geoip failed"
  # end
# end


# SCRIPT TO GET REPS FOR A ZIP #

# contents = CSV.read('./allzips.csv', :encoding => 'windows-1251:utf-8')

# contents.each() do |row|
#   zip = row[0]
#   result = HTTParty.get("http://congress.api.sunlightfoundation.com/legislators/locate?apikey=0268e7d928694dfe85b778415c844a66&chamber=senate&zip=#{zip}").parsed_response
#   #puts result.inspect()
#   result["results"].each() do |leg|
#     begin 
#       title = leg["title"]
#       firstname = leg["first_name"]
#       lastname = leg["last_name"]
#       party = leg["party"]
#       state = leg["state"]
#       chamber = leg["chamber"]
#     rescue
#       title = firstname = lastname = party = state = ""
#     end
#     if (chamber == "house")
#       print "#{zip}|#{title} #{firstname} #{lastname} (#{party}-#{state})\n"
#     end
#   end
# end


  

# {"bioguide_id"=>"R000409", "birthday"=>"1947-06-21", "chamber"=>"house", "contact_form"=>"http://rohrabacher.house.gov/Contact/Zip.htm", "crp_id"=>"N00007151", "district"=>48, "facebook_id"=>"78476240421", "fax"=>"202-225-0145", "fec_ids"=>["H8CA42061"], "first_name"=>"Dana", "gender"=>"M", "govtrack_id"=>"400343", "in_office"=>true, "last_name"=>"Rohrabacher", "middle_name"=>"T.", "name_suffix"=>nil, "nickname"=>nil, "office"=>"2300 Rayburn House Office Building", "party"=>"R", "phone"=>"202-225-2415", "state"=>"CA", "state_name"=>"California", "thomas_id"=>"00979", "title"=>"Rep", "twitter_id"=>nil, "votesmart_id"=>26763, "website"=>"http://www.house.gov/rohrabacher", "youtube_id"=>nil},

#  {"bioguide_id"=>"C001064", "birthday"=>"1955-07-19", "chamber"=>"house", "contact_form"=>"http://campbell.house.gov/Contact/ContactForm.htm", "crp_id"=>"N00027565", "district"=>45, "facebook_id"=>"JohnCampbell", "fax"=>"202-225-9177", "fec_ids"=>["H6CA48039"], "first_name"=>"John", "gender"=>"M", "govtrack_id"=>"412011", "in_office"=>true, "last_name"=>"Campbell", "middle_name"=>"Bayard Taylor", "name_suffix"=>"III", "nickname"=>nil, "office"=>"2331 Rayburn House Office Building", "party"=>"R", "phone"=>"202-225-5611", "state"=>"CA", "state_name"=>"California", "thomas_id"=>"01816", "title"=>"Rep", "twitter_id"=>"RepJohnCampbell", "votesmart_id"=>29368, "website"=>"http://www.campbell.house.gov", "youtube_id"=>"RepJohnCampbellCA48"}, {"bioguide_id"=>"B000711", "birthday"=>"1940-11-11", "chamber"=>"senate", "contact_form"=>"http://www.boxer.senate.gov/en/contact/", "crp_id"=>"N00006692", "district"=>nil, "facebook_id"=>"senatorboxer", "fax"=>"202-224-0454", "fec_ids"=>["S2CA00286"], "first_name"=>"Barbara", "gender"=>"F", "govtrack_id"=>"300011", "in_office"=>true, "last_name"=>"Boxer", "lis_id"=>"S223", "middle_name"=>nil, "name_suffix"=>nil, "nickname"=>nil, "office"=>"112 Hart Senate Office Building", "party"=>"D", "phone"=>"202-224-3553", "senate_class"=>3, "state"=>"CA", "state_name"=>"California", "state_rank"=>"junior", "thomas_id"=>"00116", "title"=>"Sen", "twitter_id"=>"senatorboxer", "votesmart_id"=>53274, "website"=>"http://www.boxer.senate.gov", "youtube_id"=>"SenatorBoxer"}, {"bioguide_id"=>"F000062", "birthday"=>"1933-06-22", "chamber"=>"senate", "contact_form"=>"http://www.feinstein.senate.gov/public/index.cfm/e-mail-me", "crp_id"=>"N00007364", "district"=>nil, "facebook_id"=>"senatorfeinstein", "fax"=>"202-228-3954", "fec_ids"=>["S0CA00199"], "first_name"=>"Dianne", "gender"=>"F", "govtrack_id"=>"300043", "in_office"=>true, "last_name"=>"Feinstein", "lis_id"=>"S221", "middle_name"=>nil, "name_suffix"=>nil, "nickname"=>nil, "office"=>"331 Hart Senate Office Building", "party"=>"D", "phone"=>"202-224-3841", "senate_class"=>1, "state"=>"CA", "state_name"=>"California", "state_rank"=>"senior", "thomas_id"=>"01332", "title"=>"Sen", "twitter_id"=>"senfeinstein", "votesmart_id"=>53273, "website"=>"http://www.feinstein.senate.gov", "youtube_id"=>"SenatorFeinstein"}], "count"=>4, "page"=>{"count"=>4, "per_page"=>20, "page"=>1}}

# puts status = result["results"].first["first_name"]


# #auth = {:username => "tt_MzA3MDA0OlI5S2MyZmx1YlBHN2tKNUZiOEhERjhmU05iOA", :password => ""}

# #contents = CSV.read('./lofgren2.csv', :encoding => 'windows-1251:utf-8')

# contents.each() do |row|
#   print row[0] + "|" + row[1] + "|" + row[2] + "|" + row[3]

#   options = {
#     :header => {
#       :user_agent=>"Postmaster/v1 RubyBindings/1.1.0", 
#       :content_type => 'application/x-www-form-urlencoded',
#       :content_length => '0',
#     },
#     :body=>{
#       :line1=>row[2],
#       :zip_code=>row[3]
#       }, 
#     :basic_auth => {
#         :username => "tt_MzA3MDA0OlI5S2MyZmx1YlBHN2tKNUZiOEhERjhmU05iOA",
#         :password => ""
#       }
#   }

#   result = HTTParty.post("https://api.postmaster.io/v1/validate", options).parsed_response
  

#   begin 
#     status = result["status"]
#     line1 = result["addresses"].first["line1"]
#     city = result["addresses"].first["city"]
#     state = result["addresses"].first["state"]
#     zip = result["addresses"].first["zip_code"]
#   rescue
#     status = result["message"]
#     zip = line1 = city = state = ""
#   end

#   output = "|#{status}|#{line1}|#{city}|#{state}|#{zip}\n"  
#   print output

# end