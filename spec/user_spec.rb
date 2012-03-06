require_relative 'spec_helper'
require_relative '../lib/user'

describe User do
 it "sould not be valid without a login or a password" do
   subject.should_not be_valid

   u1 = User.new 
   u1.login = 'testPresence'
   u1.should_not be_valid

   u2 = User.new 
   u2.password = 'testPresence'
   u2.should_not be_valid
  end

 it "should not be valid when login already exists" do
  u1 = User.new
  u1.login = 'testUniqueness'
  u1.password = 'testUniqueness'
  u1.save

  u2 = User.new
  u2.login = 'testUniqueness'  
  u2.password = 'testUniqueness' 
  u2.should_not be_valid
end

end
