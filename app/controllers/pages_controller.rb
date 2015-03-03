class PagesController < ApplicationController
  def home
  	Input.delete_all
  	@userInput = Input.new
  	@userInput.save
  	render :home
  end

  def checkInput
  	@cityUserInput = params[:city]
  	@city1UserInput = params[:city1]
  	@stateUserInput = params[:state]
  	@userInput = Input.find(Input.first.id)

  	#If City filled in, pass it on
  	if @cityUserInput.length != 0
  		@userInput.searchStyle = "city"
  		@userInput.city = @cityUserInput
  		@userInput.save
  		redirect_to :action => "airportSelect"
  	else
  		#Otherwise check if city AND state are filled in
  		if @city1UserInput.length == 0 || @stateUserInput.length == 0
  			flash[:error] = "User must enter something!"
  			redirect_to :action => "home"
  		else
  			@userInput.searchStyle = "cityState"
  			@userInput.city = @city1UserInput
  			@userInput.state = @stateUserInput
  			@userInput.save
  			redirect_to :action => "airportSelect"
  		end
  	end
  end

  def airportSelect
  	puts "In airportSelect"
    @userInput = Input.find(Input.first.id)
  	@cityUserInput = @userInput.city
  	@stateUserInput = @userInput.state
  	@searchStyle = @userInput.searchStyle
    @searchString = ""
    if @searchStyle == "cityState"
      @searchString = "Airports near "+@cityUserInput+","+@stateUserInput
    else
      @searchString = "Airports near "+@cityUserInput
    end
    @results = Geocoder.search(@searchString)
  	if @results.size > 1
  		puts "Rendering airportSelect"
      render :airportSelect
  	elsif @results.size == 1
      puts "Going to weatherDisplay"
      @userInput.airport = 0
      @userInput.save

  		redirect_to :action => "weatherDisplay"
    else
      puts "No airports exist. Going back to home"
      flash[:error] = "No airports exist. Please try again"
      redirect_to :action => "home"
  	end
  end

  def airportCheckInput
    puts "In airportCheckInput"
    @userInput = Input.find(Input.first.id)
    @userInput.airport = params[:commit][0]
    @userInput.save
    redirect_to :action => "weatherDisplay"
  end

  def weatherDisplay
    puts "In weatherDisplay"
    @userInput = Input.find(Input.first.id)
    @cityUserInput = @userInput.city
    @stateUserInput = @userInput.state
    @searchStyle = @userInput.searchStyle
    @searchString = ""
    if @searchStyle == "cityState"
      @searchString = "Airports near "+@cityUserInput+","+@stateUserInput
    else
      @searchString = "Airports near "+@cityUserInput
    end
    @results = Geocoder.search(@searchString)
    puts @results
    @address = @results[@userInput.airport.to_i].address
    @lat = @results[@userInput.airport.to_i].latitude
    @lon = @results[@userInput.airport.to_i].longitude

    @weatherStr = RestClient.get 'http://api.openweathermap.org/data/2.5/weather', :params => {:lat => @lat.to_s, :lon => @lon.to_s, :units => "imperial"}

    @weather = JSON.parse(@weatherStr)

    @sunrise = Time.at(@weather['sys']['sunrise'])
    @sunset = Time.at(@weather['sys']['sunset'])

    @windDegNum = @weather['wind']['deg']
    @windDir = ""

    if @windDegNum > 348.75 || @windDegNum < 11.25
      @windDir = "N"
    elsif @windDegNum.between?(11.25,33.75)
      @windDir = "NNE"
    elsif @windDegNum.between?(33.75,56.25)
      @windDir = "NE"
    elsif @windDegNum.between?(56.25,78.75)
      @windDir = "ENE"
    elsif @windDegNum.between?(78.75,101.25)
      @windDir = "E"
    elsif @windDegNum.between?(101.25,123.75)
      @windDir = "ESE"
    elsif @windDegNum.between?(123.75,146.25)
      @windDir = "SE"
    elsif @windDegNum.between?(146.25,168.75)
      @windDir = "SSE"
    elsif @windDegNum.between?(168.75,191.25)
      @windDir = "S"
    elsif @windDegNum.between?(191.25,213.75)
      @windDir = "SSW"
    elsif @windDegNum.between?(213.75,236.25)
      @windDir = "SW"
    elsif @windDegNum.between?(236.25,258.75)
      @windDir = "WSW"
    elsif @windDegNum.between?(258.75,281.25)
      @windDir = "W"
    elsif @windDegNum.between?(281.25,303.75)
      @windDir = "WNW"
    elsif @windDegNum.between?(303.75,326.25)
      @windDir = "NW"
    elsif @windDegNum.between?(326.25,348.75)
      @windDir = "NNW"
    end

    render :weatherDisplay
  end
end
