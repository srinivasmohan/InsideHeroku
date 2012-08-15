require 'sinatra/base'
require 'cgi'
require 'ohai'

class InsideHeroku < Sinatra::Base
	configure do
		Debug=ENV.has_key?('DEBUG') && ENV['DEBUG'] == "1"? true: false
		$stdout.sync = true
		#Setup signal handlers (notification only)
        %w{TERM INT}.each do |thissig|
            Signal.trap(thissig) do
            $stderr.puts "Received SIG#{thissig}, shutting down"
            end
        end
        set :app_file, __FILE__
		set :port, ENV['PORT']
        set :root, File.dirname(__FILE__)
        set :public, "#{File.dirname(__FILE__)}/public"
	end #End of configure block

	def getfromOhai
		thissys=Ohai::System.new
		thissys.all_plugins
		return thissys.to_json
	end

	#Initialize Ohai and grab full system info as a json object.
	get '/envinfo' do
		content_type :json
		return getfromOhai	
	end

	get '/' do
		redirect "/index.html"
	end

run! if app_file == $0

end
