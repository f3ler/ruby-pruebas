array = [ "H","L","A" ]
array.each {|i| puts i }

puts "\n"

%w{1 2 3 a b c palabra}.each {|i| puts i  }

puts ""

[ "H","L","A" ].collect {|x| puts x.succ }

