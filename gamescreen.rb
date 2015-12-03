require 'console_splash'
require 'io/console'


#create an enum to track the status of the game
class GAME < ActiveRecord::Base
  Enum status: [:MENU,:SPLASH,:INGAME ]
end

#declare variables and constants
arrRowCount=0
arrGame = Array[10][10]



#create the splash screen
def makeSplash
  splash = ConsoleSplash.new(15,70)
  splash.write_header("Welcome to Sokoban","Ben Cornforth","Alpha Build, November 2015")
  splash.write_horizontal_pattern("/*")
  splash.write_vertical_pattern("/")
  splash.splash
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

  puts "You are at the menu for Sokoban \n"
  puts "To play: press 'p'\n"
  puts "To go back to the splash screen: press 'b'"
  charPressed
end
def charPressed
  char = pressKey
  case (char)
    when "p"
      return "p"
    when "q"
      return "q"
  end
end
def toGame
  #print out the first level
  puts "\n"
  File.open("./levels/level1.xsb", "r") do |f|
    f.each_line do |line|
      puts line
      print line
    end
  end
end
#<-----------THE USER WILL BEGIN INTERACTING HERE---------->
makeSplash
if charPressed =="p"
  menuScreen
end




