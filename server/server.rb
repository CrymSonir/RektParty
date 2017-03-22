require 'sinatra'
set :bind, '0.0.0.0'
require 'mongoid'
Mongoid.load!('./mongoid.yml')
require 'json'
require 'jwt'
require_relative 'classes'

hmac_secret = 'my$ecretK3y'

get '/json' do
  content_type :json
  { :allo => 'keke', :bonjour => 'yoyo' }.to_json
end

before /^(?!\/(register|login))/ do
  if(!params[:token])
    halt 300, "Missing token"
  end
  begin
    decoded_token = JWT.decode params[:token], hmac_secret, true, { :algorithm => 'HS256' }
    decoded_token = decoded_token[0]
    User.find_by(mail: decoded_token[:mail], password: decoded_token[:password]) do |user|
      pass
    end
  rescue
    halt 300, "Invalid token"
  end
end

post '/register' do
  newUser = User.new(
    :mail => params[:mail],
    :pseudo => params[:pseudo],
    :password => params[:password],
    :birthDate => params[:birthDate],
    :firstName => params[:firstName],
    :lastName => params[:lastName]
  )
  User.find_by(mail: newUser.mail) do |user|
    halt 500, "User already exist"
  end
  newUser.save
  content_type :json
  newUser.to_json
end

post '/login' do
  mail = params[:mail]
  password = params[:password]
  User.find_by(mail: mail, password: password) do |user|
    userData = {
      :mail => user[:mail],
      :pseudo => user[:pseudo],
      :password => user[:password],
      :birthDate => user[:birthDate],
      :firstName => user[:firstName],
      :lastName => user[:lastName],
      :groups => user[:groups],
      :events => user[:events]
    }
    token = JWT.encode userData, hmac_secret, 'HS256'
    content_type :json
    halt 200, token
    return
  end
  halt 300, "Mail or password invalid"
end

get '/event' do
  Event.find_by(id: params[:_id]) do |event|
    halt 200, event.to_json
  end
  halt 500, "Event not found"
end

get '/event/all' do
  decoded_token = JWT.decode params[:token], hmac_secret, true, { :algorithm => 'HS256' }
  decoded_token = decoded_token[0]
  User.find_by(mail: decoded_token["mail"]) do |user|
    Event.find(user.event_ids) do |events|
      halt 200, events.to_json
    end
  end
  halt 500, "Event not found"
end

post '/event' do
  decoded_token = JWT.decode params[:token], hmac_secret, true, { :algorithm => 'HS256' }
  decoded_token = decoded_token[0]

  User.find_by(mail: decoded_token["mail"]) do |user|
    coordinates = params[:latitude] + "|" + params[:longitude]
    newEvent = Event.new(
      :name => params[:name],
      :dateStart => params[:dateStart],
      :dateEnd => params[:dateEnd],
      :private => params[:private],
      :status => params[:status],
      :location => params[:location],
      :coordinates => coordinates,
      :organisator => user._id
    )
    newEvent.save
    content_type :json
    halt 200, newEvent.to_json
  end
end

put '/event' do
  Event.find_by(_id: params[:_id]) do |event|
    coordinates = params[:latitude] + "|" + params[:longitude]
    event["name"] = params[:name]
    event["dateStart"] = params[:dateStart]
    event["dateEnd"] = params[:dateEnd]
    event["private"] = params[:private]
    event["status"] = params[:status]
    event["location"] = params[:location]
    event["coordinates"] = params[:coordinates]

    content_type :json
    halt 200
  end
end

put '/event/join' do
  decoded_token = JWT.decode params[:token], hmac_secret, true, { :algorithm => 'HS256' }
  decoded_token = decoded_token[0]

  User.find_by(mail: decoded_token["mail"]) do |user|
    Event.find_by(_id: params[:_id]) do |event|
      event.users.push(user)
    end
  end
end

put '/user' do
  decoded_token = JWT.decode params[:token], hmac_secret, true, { :algorithm => 'HS256' }
  decoded_token = decoded_token[0]
  puts decoded_token["mail"]
  User.find_by(mail: decoded_token["mail"]) do |user|
    puts user
    puts params
    if (params[:mail])
      user.update_attribute(:mail, params[:mail])
    end
    if (params[:pseudo])
      user.update_attribute(:pseudo, params[:pseudo])
    end
    if (params[:password])
      user.update_attribute(:password, params[:password])
    end
    if (params[:birthDate])
      user.update_attribute(:birthDate, params[:birthDate])
    end
    if (params[:firstName])
      user.update_attribute(:firstName, params[:firstName])
    end
    if (params[:lastName])
      user.update_attribute(:lastName, params[:lastName])
    end

    content_type :json
    halt 200
  end
end
