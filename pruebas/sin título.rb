#Suma de todos los numeros de 1 al 100
array = []
for i in 0...101
	array.push(i)
end

puts array.inject(0) {|sum, element| sum+element}

