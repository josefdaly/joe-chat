require 'sinatra'
require 'sinatra-websocket'
require 'json'


class ChatApp < Sinatra::Application

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
          if settings.sockets[path]
            settings.sockets[path].push(ws)
          else
            settings.sockets[path] = [ws]
          end
        end

        ws.onmessage do |msg|
          EM.next_tick {
            msg = JSON.parse(msg)
            if msg['type'] == 'update-request'
              num_users = settings.sockets[path].count
              settings.sockets[path].each do |s|
                s.send(
                 {
                   type: 'status-update',
                   num_users: num_users
                 }.to_json
                )
              end
            elsif msg['type'] == 'group-message'
              settings.sockets[path].each do |s|
                s.send(
                  {
                    type: 'group-message',
                    sender: msg['sender'],
                    content: msg['content']
                  }.to_json
                )
              end
            end
          }
        end
        ws.onclose do
          warn("websocket closed")
          settings.sockets[path].delete(ws)
        end
      end
    end
  end
end
