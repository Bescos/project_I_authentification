require_relative 'spec_helper'

describe Application do
 	context "Test with 2 applications" do
		before(:each) do
		  @a1 = Application.new 
		  @a1.name = 'testApplication'
		  @a1.url = 'http://testApplication'
		  @a1.user_id = '1'
		  @a1.should be_valid
		  @a1.save
		end
		after(:each) do
		  Application.all.each{|a| a.destroy}
			User.all.each{|u| u.destroy}
		end

		it "sould not be valid without a name" do
		  @a1.name = nil
		  @a1.should_not be_valid
		end
		it "sould not be valid without an url" do
		  @a1.url = nil
		  @a1.should_not be_valid
		end
		it "sould not be valid without an user_id" do
		  @a1.user_id = nil
		  @a1.should_not be_valid
		end

		context "Uniqueness of url and name" do
			 before (:each) do
				@a2=Application.new
				@a2.name = 'testApplication2' 
				@a2.url = 'http://testApplication2' 
				@a2.user_id = '2'
			 end

			 it "should not be valid if name already exists" do
			 @a2.name = 'testApplication'  
			 @a2.should_not be_valid
			 end
			 it "should not be valid if url already exists" do
				@a2.url = 'http://testApplication' 
				@a2.should_not be_valid
			 end
		end

		context "Link with a user" do
			before (:each) do
				@u = User.new
				@u.login = "TestValid"
				@u.password = "TestValid"
				@u.should be_valid
		    @u.save
		 	end
			after(:each) do
				User.all.each{|u| u.destroy}
			end

			it "should be valid with the id of the user" do
				@a1.user_id = @u
				@a1.should be_valid
			end
		end
	end

	describe "Application authentication method" do
		context "Application validition test" do
			before(:each) do
				@a = Application.new
				@a.name = "appli_cliente_1"
				@a.url = "http://appli_cliente_1"
				@a.user_id = '1'
				@a.save
			end

			it "should authenticate the application" do
				Application.authentication("appli_cliente_1").should == "http://appli_cliente_1"
			end
			it "should not authenticate the application" do
				Application.authentication("appli_cliente_2").should be_nil
			end
		end
	end
 
	describe "Application deletion method" do
		context "Application deletion" do
			it "should delete the application" do
				@a1 = Application.new 
		  	@a1.name = 'testApplication'
		  	@a1.url = 'http://testApplication'
		  	@a1.user_id = '1'
		  	@a1.should be_valid
		  	@a1.save
				Application.delete(@a1)
				Application.find_by_id(@a1).should be_nil				
			end
		end
	end
	
end
