require 'console_splash'
require 'io/console'

#declare variables and constants
@levelArr = []
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
  manPosition=locateMan
  char = pressKey
  #remember that the man is tracked by characters across, and characters down
  #manPosition[0] is the x coordinate of the man, hence manPosition[1] is the y
  case (char)
    when "\e[A"
      #move down
      newYCoord=manPosition[1]-1
      checkMovement(manPosition[0]-1,manPosition[1],manPosition[0]-1,newYCoord)
      displayArray
    when "\e[B"
      #move up
      newYCoord=manPosition[1]+1
      puts newYCoord
      checkMovement(manPosition[0]-1,manPosition[1],manPosition[0]-1,newYCoord)
      displayArray
    when "\e[C"
      #move right
      newXCoord=manPosition[0]+1
      checkMovement(manPosition[0]-1,manPosition[1],newXCoord-1,manPosition[1])
      displayArray
    when "\e[D"
      #move left
      newXCoord=manPosition[0]-1
      checkMovement(manPosition[0]-1,manPosition[1],newXCoord-1,manPosition[1])
      displayArray
    when "l"
      selectLevel
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
#input the new x and y coordinates
def checkMovement(oldX,oldY,proposedX,proposedY)
  #initialize the value to return
  proposedLocation=@levelArr[proposedY][proposedX]
  print @levelArr[oldY][oldX]
  case(proposedLocation)
    when "#"
      return
    when "$"
      moveBox(oldX,oldY,proposedX,proposedY)
      moveMan(oldX,oldY,proposedX,proposedY)
      return
    when "."
      return
    else
      #if man is allowed to move, run this
      moveMan(oldX,oldY,proposedX,proposedY)
  end
end
def selectLevel
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
       clearScreen
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
    @levelArr = []
    lineCount=0
    File.readlines("./levels/level#{@levelNo}.xsb").each do |line|
      charCount=0
      #initialise all y values
      @levelArr[lineCount] ||=[]
      charArr = line.split(/(?!^)/)

      @levelArr.push(charArr)
    end
    puts
    lineCount+=1
end
    #remove null values/representing spaces in ruby


#this is a method to load the array to the game screen and locate the man
def displayArray
  clearScreen
  #Loop through each char in the array and print
  @levelArr.each do |y|
    y.each do |x|
      print x
    end
  end
  manPosition = locateMan
  puts "Player is located at #{manPosition[0]} across, and #{manPosition[1]} down"
  charPressedInGame
end
def moveMan(oldX,oldY,newX,newY)
  @levelArr[oldY][oldX]=" "
  @levelArr[newY][newX]="@"
end
def moveBox(oldX,oldY,newX,newY)
  xDirection=newX-oldX
  yDirection=newY-oldY
  @levelArr[newY][newX]=" "
  @levelArr[newY+yDirection][newX+xDirection]="$"
end
#creating an array for locateMan, where the 0th element is x across, and the 1st element is y down
def locateMan
  yDown=0
  @levelArr.each do |y|
    xAcross=1
    y.each do |x|
      if x =="@"
        return xAcross,yDown
      end
      xAcross+=1
    end
    yDown+=1
  end
end
#<-----------THE USER WILL BEGIN INTERACTING HERE---------->
makeSplash
