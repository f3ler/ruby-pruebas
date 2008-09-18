puts "Hola\n"

persona1 = "Juan"
persona2 = persona1

persona1[0]= "Y"

puts persona1 + "\n" + persona2

puts "\nLas dos variables han cambiado!!"
puts "Solucion: utilizar el metodo de clase .dup. Vamos a probar:\n\n"

persona3 = "Juan"
persona4 = persona3.dup

persona3[0]= "Y"

puts persona3 + "\n" + persona4

puts "\nFunciono!!"
