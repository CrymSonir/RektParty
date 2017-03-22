require 'mongoid'
Mongoid.configure do |config|
    config.connect_to("iosProject")
end
require_relative 'classes'
bob = User.new(:mail => 'test', :password => 'pass', :pseudo => 'testPseudo', :birthDate => '07/03/1980', :firstName => 'Bobby', :lastName => 'la Menace')
bob.save
print('ALLO LE MONDE : ', bob._id)
