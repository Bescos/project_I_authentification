require 'active_record'
require 'digest/sha1'

class User < ActiveRecord::Base
  validates :login, :presence => true
  validates :password, :presence => true
  validates :login, :uniqueness => true


def password=(pass)
  unless pass.nil?
   self[:password] = User.encrypt_password(pass)
  end
end

def self.encrypt_password(pass)
    Digest::SHA1.hexdigest(pass).inspect
end

end
