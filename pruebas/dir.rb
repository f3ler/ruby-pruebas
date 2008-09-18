#!/usr/bin/ruby
dir = Dir.glob('**/*').each { | file | file.downcase }.sort
#puts dir

dir.each { | archivo | 
ruby = archivo.split(".")
if ruby[-1] == 'rb'
	puts archivo + ' Es un script de ruby!'
end

}
