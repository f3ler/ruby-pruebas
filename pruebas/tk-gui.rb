require 'tk'
root = TkRoot.new { title "Hola" }
def ponerLabel(texto)
	TkLabel.new(root) do
		text texto
		pack { padx 15 ; pady 15; side 'left' }
	end	
end
TkLabel.new(root) do
  text 'Hola!'
  pack { padx 15 ; pady 15; side 'left' }
end
TkLabel.new(root) do
  text 'Los archivos que hay en el directorio son:'
  pack { padx 15 ; pady 15; side 'left' }
end
archivos = Dir.glob('**/*').each { | file | file.downcase }.sort
archivos.each do | nombre |
	TkLabel.new(root) do
  		text nombre
  		pack { padx 15 ; pady 15; side 'left' }
	end
end
TkButton.new(root) do
	text 'Click!'
	command { ponerLabel('a') }
	pack { padx 15 ; pady 15; side 'left' }
end
Tk.mainloop
