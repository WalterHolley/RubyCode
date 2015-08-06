require 'net/http'
require 'rexml/document'
require 'cgi'

include REXML

COUNTRY_NAME = "United States"
HOST = "http://www.webservicex.com/globalweather.asmx"
HTTP_ACTION = "GetWeather"



#Validate city value entered
def validateCityName(cityName)
  cityName = cityName.strip
  cityRegex = /^([A-Za-z])+([^0-9{}|()!@#$%^&*~_"':;<>,?\-])*/

  if cityName.length == 0
    puts "City name not entered.  Please try again."
    return false
  end

  match = cityRegex.match(cityName).to_s

  puts match

  if match.eql? cityName
    puts "City validated"
    return true
  else
    puts "City did not pass validation"
    return false
  end

end

def performSOAPRequest(cityName)


  params = {:CityName => cityName, :CountryName => COUNTRY_NAME}

  uri = URI(HOST + '/' + HTTP_ACTION + '?')
  uri.query = URI.encode_www_form(params)
  #response = Net::HTTP.get(uri)
  response = Net::HTTP.get_response(uri)

  if response.is_a?(Net::HTTPSuccess)

      xml = Document.new(CGI::unescapeHTML(response.body))
      weather = xml.elements().to_a('string/CurrentWeather').first


      if weather.nil?
        puts "City not found.  Try a different spelling or a different city."
        return false
      end

      location = weather.elements().to_a('Location').first.text
      temp = weather.elements().to_a('Temperature').first.text

      puts "Location: " + location
      puts "Temperature: " + temp
    else
      puts "SOAP Request failed. Code: " + response.code
      return false
  end
  return true
end


#Testing Cities used:
#Lexington
#St. Louis

###MAIN EXECUTION###
$cityIsValid = false
$responseSuccessful = false
$cityName = ""

while $cityIsValid == false || $responseSuccessful == false
  puts "Please enter a City Name: "
  $cityName = gets.chomp
  $cityIsValid = validateCityName($cityName)

  if $cityIsValid
    $responseSuccessful = performSOAPRequest($cityName)

  end
end



###END EXECUTION###
