class User
  include Mongoid::Document
  field :mail
  field :pseudo
  field :password
  field :birthDate
  field :firstName
  field :lastName
  has_and_belongs_to_many :groups, :inverse_of => :users, :class_name => 'Group'
  has_and_belongs_to_many :events, :inverse_of => :users, :class_name => 'Event'
  has_one :event, :inverse_of => :user, :class_name => 'Event'
end

class Group
  include Mongoid::Document
  field :name
  has_and_belongs_to_many :users, :inverse_of => :groups, :class_name => 'User'
  has_and_belongs_to_many :events, :inverse_of => :groups, :class_name => 'Event'
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
  has_and_belongs_to_many :users, :inverse_of => :events, :class_name => 'User'
  has_and_belongs_to_many :groups, :inverse_of => :events, :class_name => 'Group'
  belongs_to :organisator, :inverse_of => :event, :class_name => 'User'
end
