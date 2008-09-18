
def calcularMCM(a,b)
	r=a*b;
    while a!=b
    	if(a>b)
        	a=a-b
    	else
        	b=b-a
    	end
	end
	max=a;
	min=r/max;
	puts min
end

puts "Bienvenido al calculador de mcm"

puts "Introduzca numero 1:"

n1 = gets.to_i

puts "Introduzca numero 2:"

n2 = gets.to_i

calcularMCM(n1,n2)
