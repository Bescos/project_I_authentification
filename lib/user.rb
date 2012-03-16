require 'active_record'
require 'digest/sha1'

class User < ActiveRecord::Base
  has_many :utilizations
  has_many :applications, :through => :utilizations

  has_many :applications
  validates :login, :presence => true
  validates :password, :presence => true
  validates :login, :uniqueness => true


def password=(pass)
  if !pass.empty?
   self[:password] = User.encrypt_password(pass)
  else 
   self[:password] = nil
  end
end

def self.encrypt_password(pass)
    Digest::SHA1.hexdigest(pass).inspect[1,40]
end

def self.authentication(params)
	u = find_by_login(params['login'])
	if u and u.password == Digest::SHA1.hexdigest(params['password'])
		true
	else
		nil
	end
end

end
