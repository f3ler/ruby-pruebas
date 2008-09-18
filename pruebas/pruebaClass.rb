class Cancion
	def initialize(name , artist , duration)
		@name = name
		@artist = artist
		@duration = duration
	end
	def to_s
		"Cancion: #@name--#@artist (#@duration)"
	end
end

Asomate = Cancion.new("asomate","Violadores del verso", 240)
puts Asomate.inspect
puts Asomate.to_s
	
