# Decisiv Test - Solution 
Hi! My name is Thiago L. and this is my solution for the VIN exercise.

# Initial considerations
I liked a lot to learn about VINs and the meaning of each part of it when we decompose; I wasn't sure if I should make suggestions of correct VINs using the NHTSA API or if I should come up with my own logic to it... So the resulting code is kind of a mix between both!

# How to use 
To run the script, just execute `ruby vin_script.rb VIN` on terminal and replace `VIN` with a real one. 

# Outcomes
- If the input has less than 17 characters, just display a message and exit.
- If the check digit is valid: Output a message and try to bring attributes for the vehicle from the NHTSA API
- If the VIN has invalid characters: Output a message and try to bring possible values for invalid characters from the NHTSA API.
- If check digit is invalid: Output a message, suggest a VIN with the correct check digit along with other variations of it, by replacing from the 10º to 17º characters with similar chars regarding its transliterations values. Also, make a request to the NHTSA API and display any possible values coming from there.

# Corrections
I also fixed what I thought was an error on the initial code: on the calculate_check_digit we have a mapping to check digits as `map = [0,1,2,3,4,5,6,7,9,10,'X']`
but on real scenarios we can't have `10` as a check digit... instead, when the remaining value is 10, the check is `X`. So I just replaced that line with 
`map = [0,1,2,3,4,5,6,7,9,'X']`
