require 'console_splash'
require 'io/console'

#declare variables and constants
@fileArr = []
@levelNo=1

#create the splash screen
def makeSplash
  clearScreen
  splash = ConsoleSplash.new(15,70)
  splash.write_header("Welcome to Sokoban","Ben Cornforth","Alpha Build, November 2015")
  splash.write_horizontal_pattern("/*")
  splash.write_vertical_pattern("/")
  splash.splash
  if pressKey != ""
    menuScreen
  end
end
#This method reads keypresses from the user including 2 and 3 escape character sequences.
def pressKey
  STDIN.echo = false
  STDIN.raw!
  input = STDIN.getc.chr
  if input == "\e" then
  input << STDIN.read_nonblock(3) rescue nil
  input << STDIN.read_nonblock(2) rescue nil
  end
ensure
  STDIN.echo = true
  STDIN.cooked!
  return input
end
#use this method to create a fresh canvas
def clearScreen
  puts "\e[H\e[2J"
end
#create a menu method to open up upon being called
def menuScreen
  clearScreen
  puts "You are at the menu for Sokoban \n"
  puts "To quick play:      Press p\n"
  puts "To choose a level:  Press c\n"
  puts "To stop:            Press q"
  charPressedInMenu
end
def charPressedInGame
  char = pressKey
  case (char)
    when "\e[A"
      #move down
    when "\e[B"
      #move up
    when "\e[C"
      #move right
    when "\e[D"
      #move left
    when "q"
      #quit
      puts "You are about to quit. To revert this, enter: n"
      puts "Otherwise, press any key to continue..."
      choiceInput = pressKey
      choiceInput.downcase
      case(choiceInput)
        when "n"
          #continue
          displayArray
          return
        else
          #leave
          @levelNo
          menuScreen
          return
      end
      menuScreen
    else
      #recurse this switch case
      charPressedInGame
  end

end
def selectLevel
  clearScreen
  puts "Choose a level from 1 - 90:"
  input = gets.chomp()
  tempLevelNo = input.to_i
  if (input == tempLevelNo.to_s)
       if 1 > tempLevelNo || tempLevelNo > 90
         puts "Level does not exist, please choose a level from 1-90"
         puts "Do you wish to continue choosing? y/n"
         case(pressKey)
           when "y"
             selectLevel
             return
           when "n"
             menuScreen
             return
         end
       else
       @levelNo = tempLevelNo
       #load onto array
       loadArray
       #display array
       displayArray
       end

  else
    puts "This is not an integer, please enter a level number which is an integer"
  end
end

#this method will be run when the user makes an action
def charPressedInMenu
  char = pressKey
  case (char)
    when "p"
      #load level of choice
      loadArray

      #displayArray
      displayArray
    when "q"
      #stop game
      exit
    when "c"
      #request level
      selectLevel

  end
end


#this is a method to load the game of choice onto the array
def loadArray
  clearScreen
  #open the file and make each line an element
  File.readlines("./levels/level#{@levelNo}.xsb").each do |line|
      #initialize the subarray 'charArr'
      charArr=[]
      line.each_char do |char|
        #push new element to the array subarray 'charArr'
        charArr.push(char)
      end
      #add the sub array 'charArr' to the whole file array 'fileArr'
      @fileArr.push(charArr)
  end
end

#this is a method to load the array to the game screen
def displayArray
  clearScreen
  #Loop through each char in the array
  @fileArr.each do |x|
    x.each do |y|
      print y
    end
  end
  charPressedInGame
end
#<-----------THE USER WILL BEGIN INTERACTING HERE---------->
makeSplash
