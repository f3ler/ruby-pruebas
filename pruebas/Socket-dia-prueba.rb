require "socket" 
print TCPSocket.open("google.es","daytime").gets
