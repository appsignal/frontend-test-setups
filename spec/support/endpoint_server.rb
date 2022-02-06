require 'sinatra/base'

class EndpointServer < Sinatra::Base
  class << self
    def run!
      puts "Starting endpoint server"
      @@mutex = Mutex.new
      @@received_requests = []
      super
    end

    def add_received_request(request)
      @@mutex.synchronize do
        @@received_requests << request
      end
    end

    def received_requests_length
      @@mutex.synchronize do
        @@received_requests.length
      end
    end

    def pop_received_request
      @@mutex.synchronize do
        @@received_requests.pop
      end
    end

    def clear
      @@mutex.synchronize do
        @@received_requests.clear
      end
    end
  end

  post '/collect' do
    EndpointServer.add_received_request(request)
  end
end
