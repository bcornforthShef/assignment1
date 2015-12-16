require 'console_splash'
require 'io/console'

#declare variables and constants
@levelArr = []
@levelNo=1
#The below variables will be used when the man goes over a dot, which saves the location of the dot in an array
@boxGoalCoord=[]

#create the splash screen
def makeSplash
  clearScreen
  splash = ConsoleSplash.new(15,70)
  splash.write_header("Welcome to Sokoban","Ben Cornforth","Alpha Build, November 2015",{:nameFg=>:green,:authorFg=>:green, :versionFg=>:green, :bg=>:black})
  splash.write_horizontal_pattern("/*",{:fg=>:white, :bg=>:black})
  splash.write_vertical_pattern("/",{:fg=>:orange, :bg=>:black})
  splash.splash
  if pressKey != ''
    menuScreen
  end
end

#use this method to create a fresh canvas
def clearScreen
  puts "\e[H\e[2J"
end


#ALL CODE USED TO NAVIGATE THE GAME IS HERE
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
#create a menu method to open up upon being called
def menuScreen
  @levelNo=1
  clearScreen
  puts "You are at the menu for Sokoban"
  puts "To quick play:      Press 'p'"
  puts "To choose a level:  Press 'c'"
  puts "To stop:            Press 'q'"
  charPressedInMenu
end
#this method will be run when the user presses a key on the keyboard
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
    else
      menuScreen
  end
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
    when 'h'
      showHelp
    when 'l'
      selectLevel
    when 'r'
      #reset the level
      puts "You are about to reset the level, to revert, enter: n"
      puts "Otherwise, press any key to continue..."
      input = pressKey
      case(input)
        when 'n'
          displayArray
          return
        else
          loadArray
          return
      end
    when 'q'
      #quit
      puts "You are about to quit. To revert this, enter: n"
      puts "Otherwise, press any key to continue..."
      choiceInput = pressKey
      case(choiceInput)
        when 'n'
          #continue
          displayArray
          return
        else
          #leave
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
def checkMovement(oldX,oldY,newX,newY)
  #initialize the value to return
  proposedLocation=@levelArr[newY][newX]
  case(proposedLocation)
    when '#'
      displayArray
    when '$'
      moveBox(oldX,oldY,newX,newY)
      return
    when '.'
      moveMan(oldX,oldY,newX,newY)
    else
      #if man is allowed to move, run this
      moveMan(oldX,oldY,newX,newY)
      return
  end
end

#this code will run when the user wants to select a level
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


#this is a method to load the game of choice onto the array
def loadArray
    clearScreen
    @boxGoalCoord=[]
    @levelArr=[]

    lineCount=0
    #open the file and make each line an element in the 2d array @levelArr
    File.readlines("./levels/level#{@levelNo}.xsb").each do |line|
      #initialize the subarray 'charArr'
      charArr=[]

      xCount=1
      line.each_char do |char|
        #push new element to the array subarray 'charArr'
        if char=='.'
          @boxGoalCoord.push("#{xCount},#{lineCount}")
        end
        charArr.push(char)
        xCount+=1
      end
      #add the sub array 'charArr' to the whole file array 'fileArr'
      @levelArr.push(charArr)
      lineCount+=1
    end
end

#this is a method to load the array to the game screen and show the player's location
def displayArray
  checkIfComplete
  clearScreen
  @levelArr.each do |y|
    y.each do |x|
      case(x)
        when '@'
          print x.colorize(:color => :orange)
        when '#'
          print x.colorize(:background => :gray)
        else
          print x
      end
    end
  end
  manPosition = locateMan
  puts "Press 'h' for help:"
  charPressedInGame
end


def showHelp
  puts "To reset the level, press 'r'"
  puts "To select a new level, press 'l'"
  puts "To quit to menu, press 'q'"
  charPressedInGame
end
#this method will move the man from the current (old) coordinates to the next coordinates (new)
def moveMan(oldX,oldY,newX,newY)
  @levelArr[newY][newX]='@'
  @levelArr[oldY][oldX]=' '
  #replace the box goals if they were overwritten by the above lines of code
  replenishBoxGoals
end

#this will determine if the box is allowed to be moved,
#which will ultimately determine if the player is allowed to move
def moveBox(oldX,oldY,newX,newY)
  xDirection=newX-oldX
  yDirection=newY-oldY
  proposedBoxPos=@levelArr[newY+yDirection][newX+xDirection]
  case(proposedBoxPos)
    when ' ','.'
      #this will run when the next possible position of the box is a blank space(' ') or is a box goal ('.')
      @levelArr[newY][newX]=' '
      @levelArr[newY+yDirection][newX+xDirection]='$'
      moveMan(oldX,oldY,newX,newY)
    else
      #otherwise, abort the process
      return
  end
  replenishBoxGoals
end
#this will reload the '.' if it has been overwritten by the player '@' or the box '$'
def replenishBoxGoals
  @boxGoalCoord.each do |coords|
    goalLocation=coords.split(/,/)
    x=goalLocation[0].to_i-1
    y=goalLocation[1].to_i
    if @levelArr[y][x]==' '
      @levelArr[y][x]='.'
    end
  end
end

#creating an array for locateMan, where the 0th element is x across, and the 1st element is y down
def locateMan
  yDown=0
  @levelArr.each do |y|
    xCount=1
    y.each do |x|
      if x == '@'
        return xCount,yDown
      end
      xCount+=1
    end
    yDown+=1
  end
end
def checkIfComplete
  finished=true
  @boxGoalCoord.each do |coords|
    goalLocation=coords.split(/,/)
    x=goalLocation[0].to_i-1
    y=goalLocation[1].to_i
    if @levelArr[y][x]!='$'
      finished=false
    end
  end
  if finished
    puts "LEVEL COMPLETE!... "
    puts "To go back to the menu, press q, to select level, press l."
    puts "Otherwise, to go the next level, press any other key:"
    case(pressKey)
      when 'q'
        menuScreen
      when 'l'
        selectLevel
      else
        @levelNo+=1
        loadArray
    end
  end

end
#<-----------THE PROGRAM WILL BEGIN HERE---------->
makeSplash
