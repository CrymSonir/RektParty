class User
  include Mongoid::Document
  field :mail
  field :pseudo
  field :password
  field :birthDate
  field :firstName
  field :lastName
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :events
end

class Group
  include Mongoid::Document
  field :name
  has_and_belongs_to_many :users
  has_and_belongs_to_many :events
end

class Event
  include Mongoid::Document
  field :name
  field :dateStart
  field :dateEnd
  field :private
  field :status
  field :location
  field :coordinates
  field :organisator
  has_and_belongs_to_many :users
  has_and_belongs_to_many :groups
end
