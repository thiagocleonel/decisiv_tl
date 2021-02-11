#VIN examples
# INKDLUOX33R385016
# 2NKWL00X16M149834
# INKDLUOX33R385016
# 1XPBDP9X1FD257820
# 1XKYDPPX4MJ442156
# 3HSDJAPRSFN657165
# JBDCUB16657005393

require 'net/http'
require 'json'

#Error raised when the VIN has invalid chars
class VINInvalidChar < StandardError; end

vin = ARGV[0].upcase

VALID_CHARS = "0123456789.ABCDEFGH..JKLMN.P.R..STUVWXYZ".split('').freeze

def transliterate(char)
  raise VINInvalidChar unless VALID_CHARS.include?(char) && char != '.'
  VALID_CHARS.index(char) % 10
end

def calculate_check_digit(vin)
  map = [0,1,2,3,4,5,6,7,8,9,'X']
  weights = [8,7,6,5,4,3,2,10,0,9,8,7,6,5,4,3,2]
  sum = 0
  vin.split('').each_with_index do |char, i|
    sum += transliterate(char) * weights[i]
  end
  map[sum % 11]
rescue VINInvalidChar
  return nil
end

def fix_digit_and_suggest(vin)
  fixed_digit = vin.chars
  fixed_digit[8] = calculate_check_digit(vin).to_s
  @suggestions = [fixed_digit.join]

  (9..16).each do |index|
    alternative_chars = VALID_CHARS.select{|char| VALID_CHARS.index(char) % 10 == VALID_CHARS.index(fixed_digit[index]) % 10 }
    alternative_chars.each do |ac|
      next if ac == fixed_digit[index] || ac == '.'
      alternative = fixed_digit.dup
      alternative[index] = ac
      @suggestions << alternative.join
      break #Limit the suggestions to a reduced set
    end
  end

  present_suggestions(@suggestions)
end

def present_suggestions(suggestions)
  return if suggestions.empty?
  puts "Suggestions with correct digit:"
  suggestions.each do |suggestion|
    puts (" - #{suggestion}")
  end
end

def valid_check_digit?(vin)
  vin[8].to_c == calculate_check_digit(vin)
end


#Consult NHTSA API to analyze the given VIN
def consult_nhtsa_api(vin, type = :possible_values)
  response = Net::HTTP.get(URI("https://vpic.nhtsa.dot.gov/api/vehicles/decodevinvalues/#{vin}?format=json"), nil,  { 'Accept' => 'application/json' })
  parsed = JSON.parse(response)
  results = parsed["Results"].first

  if type == :more_info
    puts "More info about the vehicle:"
    puts "- Engine model: #{results["EngineModel"]}"
    puts "- Fuel type primary model: #{results["FuelTypePrimary"]}"
    puts "- Manufacturer: #{results["Manufacturer"]}"
  elsif type == :possible_values
    if results["PossibleValues"] != "" then puts(" Possible Values for wrong chars: #{results["PossibleValues"]}") end
  end

rescue StandardError => e
  puts "Unable to reach NHTSA API"
end

if vin.size != 17
  puts("Invalid VIN length (#{vin.size} != 17 )")
  exit
end

puts "Provided VIN:\t#{vin}"
puts "Check Digit: #{valid_check_digit?(vin) ? "VALID" : "INVALID"}"

if valid_check_digit?(vin)
  puts "This looks like a valid VIN!"
  consult_nhtsa_api(vin, :more_info)
elsif calculate_check_digit(vin) == nil #Not allowed chars found
  puts "Invalid character(s) found, please replace the following(s) '!' with a valid character."
  puts vin.chars.map{|char| VALID_CHARS.include?(char) && char != '.' ? char : '!'}.join
  consult_nhtsa_api(vin, :possible_values)
else
  fix_digit_and_suggest(vin) #Replace check digit to the correct one and suggests variations
  consult_nhtsa_api(vin, :possible_values)
end
