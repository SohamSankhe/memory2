defmodule Memory.Game do

# Ref: Hangman example done in class
  
  # constructor for new state
  def new do
    %{
      valueList: generateValueList(),
      prevGuess: -1,
      currentGuess: -1,
      delay: -1,
      score: 0,
    }
  end
  
  # debugging
  def displayState(game) do
  	Enum.map(game.valueList, fn x -> 
  		IO.puts(x.buttonValue)
  		IO.puts(x.isGuessed)
  	end)
  	IO.puts("preGuess")
  	IO.puts(game.prevGuess)
  	IO.puts("Current Guess")
  	IO.puts(game.currentGuess)
  end
  
  # restricted view
  def client_view(game) do
  	#displayState(game)
    values = game.valueList
    sr = game.score
    %{
      displayList: generateDisplayList(game),
      score: sr,
      delay: game.delay
    }
  end

  # handling of events server side
  def guess(game, letter) do
    cond do
    	letter == -1 -> handleDelay(game)
    	letter == -2 -> new()
    	Enum.at(game.valueList, letter).isGuessed -> game
    	letter == game.prevGuess -> game
    	letter == game.currentGuess -> game
    	game.prevGuess == -1 -> Map.put(game, :prevGuess, letter)
    	Enum.at(game.valueList, letter).buttonValue == Enum.at(game.valueList, game.prevGuess).buttonValue -> processMatch(game, letter)
    	true -> processMismatch(game, letter)
    end
  end

  def handleDelay(game) do
  	game = Map.put(game, :delay, -1)
  	game = Map.put(game, :prevGuess, -1);
  	game = Map.put(game, :currentGuess, -1);
  end

  def processMismatch(game, letter) do
  	game = Map.put(game, :currentGuess, letter)
  	game = Map.put(game, :score, game.score - 2)
  	Map.put(game, :delay, 1)
  end

  #def delayFunc(game, index) do
  #	game = Map.put(game, :prevGuess, -1);
  #	game = Map.put(game, :currentGuess, -1);
  #	Map.put(game, :delay, -1);
  #end

  def processMatch(game, letter) do
    # set isGuessed for prev and letter to true
    # reset prevGuess to -1
    
  	lst = Enum.with_index(game.valueList)
  	newValueList = Enum.reduce(lst, [], fn({x, index}, acc) ->
  		cond do
  			index == letter -> acc ++ [%{buttonValue: x.buttonValue, isGuessed: true}]
  			index == game.prevGuess -> acc ++ [%{buttonValue: x.buttonValue, isGuessed: true}]
  			true -> acc ++ [x]
  		end
  	end)
  	game = Map.put(game, :valueList, newValueList)
  	game = Map.put(game, :score, game.score + 10)
  	Map.put(game, :prevGuess, -1)
  end

  # list with tiles that are to be displayed
  def generateDisplayList(game) do
    lst = Enum.with_index(game.valueList)
  	Enum.reduce(lst, [], fn({x, index}, acc) -> 
			cond do
				x.isGuessed -> acc ++ [x.buttonValue]
				index == game.prevGuess -> acc ++ [x.buttonValue]
				index == game.currentGuess -> acc ++ [x.buttonValue]
				# add what is not matching
				true -> acc ++ [""]
			end
	end)
  end

  def generateValueList do
  	charSet = [:A,:B,:C,:D,:E,:F,:G,:H,:A,:B,:C,:D,:E,:F,:G,:H]
	shuffleSet = Enum.shuffle(charSet)
	randomAssign([], shuffleSet, 0)
  end

  def randomAssign(lst, shuffleSet, counter) do
		cond do
			counter == 16 -> lst
			true -> randomAssign(lst ++ [%{buttonValue: Enum.at(shuffleSet, counter), isGuessed: false}], shuffleSet, counter + 1)
		end
  end

  def getIntegerValue(str) do
  	{integerVal, ""} = Integer.parse(str)
  	integerVal
  end
end
