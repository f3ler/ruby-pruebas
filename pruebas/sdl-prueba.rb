require 'sdl'

puts 'Inicializando SDL...'
SDL.init(SDL::INIT_EVERYTHING)
puts 'Inicializado'

puts 'Estamos en la version de Ruby/SDL :'
puts SDL::VERSION
