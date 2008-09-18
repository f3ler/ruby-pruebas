#! /usr/bin/ruby -w
require 'sdl'
 
SDL.init SDL::INIT_VIDEO
screen = SDL::set_video_mode 640, 480, 24, SDL::SWSURFACE
x = y = 0

BGCOLOR = screen.format.mapRGB 5, 100, 200
LINECOLOR = screen.format.mapRGB 255, 255, 255
PIXELCOLOR = screen.format.mapRGB 0, 0, 0

running = true

SDL::Mouse.hide
 
while running
   while event = SDL::Event2.poll
     case event
     when SDL::Event2::Quit
        running = false
     when SDL::Event2::MouseMotion
       x = event.x
       y = event.y
       end
   end
   screen.fill_rect 0, 0, 640, 480, BGCOLOR
   screen.draw_line x, 0, x, 479, LINECOLOR
   screen.draw_line x+2, 0, x+2, 479, LINECOLOR
   screen.draw_line 0, y, 639, y, LINECOLOR
   screen.flip
 end
