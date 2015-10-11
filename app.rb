require 'sinatra'
require 'sinatra-websocket'
require 'json'


class ChatApp < Sinatra::Application

  set :server, 'thin'
  set :sockets, {}

  get '/' do
    erb :index
  end

  get '/open_rooms' do
    content_type :json

    rooms = {}
    settings.sockets.keys.each do |room_key|
      user_count = settings.sockets[room_key].count
      rooms[room_key] = user_count if user_count > 0
    end

    rooms.to_json
  end

  get '/:path' do
    path = params[:path]
    if !request.websocket?
      erb :chatroom
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
