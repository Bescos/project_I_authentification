$: << File.dirname(__FILE__)
require 'utilization'

class Application < ActiveRecord::Base
  belongs_to :user
  
  has_many :utilizations, :dependent => :destroy
  has_many :users, :through => :utilizations

  validates :name, :presence => true
  validates :url, :presence => true
  validates :user_id, :presence => true

  validates :name, :uniqueness => true
  validates :url, :uniqueness => true
  
#Send back URL if auth is OK
def self.authentication(name) 
	a = find_by_name(name)
	if a
		a.url
	end
end

end


