require 'socket'

DocRoot = "document_root"
index = "index.html"

def getFile(file)
	path = File::join DocRoot, file
	if path == DocRoot + "/"
		path = path.chomp "/"
	end
	
	if File::exist? path
		return path
	else
		return nil
	end
end

class Parse 
	def initialize(line)
		@line = line
	end
	def request
		return @line.split(" ")
	end
	def parse
		requested = self.request
		return requested 
	end

class HTTPConnection
	def initialize(port)
		begin 
			@socketInstance = TCPServer.new('localhost', port)
			@socketRunning = true
		rescue
			puts "Connection couldn't be made: #{$!}"
		end
	end
	def session
	loop {	
		Thread.start(@socketInstance.accept) do |Session|
		httpRequest = Session.gets
		f = Parse.new(httpRequest)
		splitRequest = f.parse
		
		if splitRequest.length != 0
			if splitRequest[0] == "GET"
				requestPath = splitRequest[1]
				fullPath = getFile(requestPath)
				
				if fullPath == DocRoot
					fullPath = File::join DocRoot, Index
					
					if not File::exist? fullPath
						fullPath = nil
					end
				end
				
				if fullPath == nil
					Session.puts "HTTP/1.1 404 Not Found"
					Session.puts "\r\n"
					else
						Session.puts "HTTP/1.1 200 OK"
						Session.puts "\r\n"
					
						n = File::open(fullPath, "r")
						n.each_line { |line| puts line }
				end			
			end
		end
		
		Session.close
    }
    end
end

if __FILE__ == $0
	httpSession = HTTPConnection.new(ARGV[0])
	httpSession.listen
end