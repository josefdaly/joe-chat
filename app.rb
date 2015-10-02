require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'
set :sockets, {}

get '/' do
  "Setup a chatroom by extending any path off the domain name and sharing the url
   with your friend."
end

get '/:path' do
  path = params[:path]
  if !request.websocket?
    erb :index
  else
    request.websocket do |ws|
      ws.onopen do
        ws.send("Hello from the server!")
        if settings.sockets[path]
          settings.sockets[path].push(ws)
        else
          settings.sockets[path] = [ws]
        end
      end
      ws.onmessage do |msg|
        EM.next_tick { settings.sockets[path].each{ |s| s.send(msg) } }
      end
      ws.onclose do
        warn("websocket closed")
        settings.sockets[path].delete(ws)
      end
    end
  end
end
