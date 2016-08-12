require 'sinatra'
require 'sinatra-websocket'
require 'json'


class ChatApp < Sinatra::Application

  set :server, 'thin'
  set :sockets, {}
  set :messages, {}

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
            settings.messages[path].each do |message|
              ws.send(message)
            end
          else
            settings.sockets[path] = [ws]
            settings.messages[path] = []
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
              message = {
                type: 'group-message',
                sender: msg['sender'],
                content: msg['content']
              }.to_json
              settings.sockets[path].each do |s|
                s.send(message)
              end
              settings.messages[path].push(message)
            end
          }
        end
        ws.onclose do
          warn("websocket closed")
          settings.sockets[path].delete(ws)
        #   if settings.sockets[path].length < 1
        #     settings.sockets.delete(path)
        #     settings.messages.delete(path)
        #   end
        end
      end
    end
  end
 
end
