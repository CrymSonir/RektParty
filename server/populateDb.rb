require 'mongoid'
Mongoid.configure do |config|
    config.connect_to("iosProject")
end
require_relative 'classes'

bob = User.new(:pseudo => 'testPseudo', :mail => 'test', :password => 'pass', :birthDate => '07/03/1980', :firstName => 'Bobby', :lastName => 'la Menace')
bob.save
print('ALLO LE MONDE : ', bob._id)
