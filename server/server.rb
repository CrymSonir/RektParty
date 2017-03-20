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
    token = JWT.encode user, hmac_secret, 'HS256'

    content_type :json
    halt 200, token.to_json
    return
  end
  halt 300, "Mail or password invalid"
end
