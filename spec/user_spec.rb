require_relative 'spec_helper'


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
  User.all.each{|u| u.destroy}
 end

 it "should encode the password with sha1" do
  User.should_receive(:encrypt_password).with('TestPassword').and_return("\"6250625b226df62870ae23af8d3fac0760d71588\"") #Return Sha1 Code of TestPassword
  u = User.new
  u.password='TestPassword'
  u.password.should == "\"6250625b226df62870ae23af8d3fac0760d71588\""
 end
 
 it "should not encode the password because its empty" do
  u = User.new
  u.login = 'testPasswordNil'
  u.password=''
  u.password.should be_nil
  u.valid?.should be_false
 end

end
