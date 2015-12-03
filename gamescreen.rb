require 'console_splash'
require 'io/console'
splash = ConsoleSplash.new(15,55)

splash.write_header("Sokoban","Ben Cornforth","Copyright 2015")
splash.write_horizontal_pattern("/*")
splash.write_vertical_pattern("/")
splash.splash

# Reads keypresses from the user including 2 and 3 escape character sequences.


#clear splash screen
def clearScreen
  puts "\e[H\e[2J"
end
#declare variables and constants

arrRowCount=0
arrGame = Array[10][10]
#open the file and play them here
puts "\n"
File.open("./levels/level1.xsb", "r") do |f|
    f.each_line do |line|
      puts line
      arrGame[]
      print line
    end
end
