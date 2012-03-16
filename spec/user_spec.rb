$: << File.join(File.dirname(__FILE__),"")
require_relative 'spec_helper'


describe User do
	describe "User creation" do
	 	context "User validity test" do
		   before(:each) do
		    @u1=User.new
				@u1.login = "TestValid"
				@u1.password = "TestValid"
				@u1.should be_valid
		    @u1.save
			 end
			 after(:each) do
				 User.all.each{|u| u.destroy}
			 end

			 it "should be valid with a login and a password" do
				@u1.should be_valid
			 end
			 it "sould not be valid without a login or a password" do
				 @u1.login = ""
				 @u1.should_not be_valid
				end
		   it "sould not be valid without a password" do
				 @u1.password = ""
				 @u1.should_not be_valid
				end
			 it "should not be valid when login already exists" do
				 u2 = User.new
				 u2.login = "TestValid" 
				 u2.password = "TestUniqueness"
				 u2.should_not be_valid
			 end
			 it "should encode the password with sha1" do
				 User.should_receive(:encrypt_password).with('TestValid').and_return("978d8399a65d10b8b3f58338f68ee72192428bd1") #Return Sha1 Code of TestPassword
		     @u1.password = "TestValid"
				 @u1.password.should == "978d8399a65d10b8b3f58338f68ee72192428bd1"
			 end
			 it "should not encode the password because its empty" do
				 @u1.password=''
				 @u1.password.should be_nil
				 @u1.valid?.should be_false
			 end
			end
		end
		describe "User authentication method" do
			context "User validity test" do
		   before(:each) do
		    @u1=User.new
				@u1.login = "toto"
				@u1.password = "toto"
				@u1.should be_valid
		    @u1.save
			 end
			 after(:each) do
				 User.all.each{|u| u.destroy}
			 end

			it "should authenticate the user" do
				 params = {'login'=>"toto",'password'=>"toto"}	
				 #subject.should_receive(:authentication).with(params).and_return(true)
				 User.authentication(params)
			end
			it "should not authenticate the user" do
				 params = {'login'=>"toto",'password'=>"tutu"}	
				# subject.should_receive(:authentication).with(params).and_return(false)
				 User.authentication(params)
			end
			end 
		end
end
