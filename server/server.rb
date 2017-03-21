require 'sinatra'
set :bind, '0.0.0.0'
require 'mongoid'
Mongoid.load!('./mongoid.yml')
require 'json'
require 'jwt'
require_relative 'classes'


get '/' do
  'Bienvenue dans l\'api'
end

get '/json' do
  content_type :json
  { :allo => 'keke', :bonjour => 'yoyo' }.to_json
end

before /^(?!\/(register|login))/ do
  if(!params[:token])
    halt 300, "Missing token"
  end
  hmac_secret = 'my$ecretK3y'
  begin
    print("PARAMS : ", params)
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
    hmac_secret = 'my$ecretK3y'
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
