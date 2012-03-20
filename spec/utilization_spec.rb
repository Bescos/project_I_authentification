require_relative 'spec_helper'


describe Utilization do
 	context "Test with 1 user and 1 application" do
		before(:all) do
		  @a1 = Application.new 
		  @a1.name = 'testApplication'
		  @a1.url = 'http://testApplication'
		  @a1.user_id = '1'
		  @a1.save
			@u1 = User.new
			@u1.login = 'testUser'
			@u1.password = 'testUser'
			@u1.save 
			@u2 = User.new
			@u2.login = 'testUser2'
			@u2.password = 'testUser2'
			@u2.save
			@a2 = Application.new 
		  @a2.name = 'testApplication2'
		  @a2.url = 'http://testApplication2'
		  @a2.user_id = '1'
		  @a2.save
		end
		after(:all) do
			User.all.each{|u| u.destroy}
		  Application.all.each{|a| a.destroy}
		end

		it "sould be valid and recognize u1 use a1" do
		  @ut = Utilization.new
			@ut.user_id = @u1.id
			@ut.application_id = @a1.id
			@ut.should be_valid
			@ut.save
			Utilization.find_by_user_id_and_application_id(@u1.id,@a1.id).should be_true
		end
		
		it "should not be valid without an user_id" do
			@ut = Utilization.new
			@ut.application_id = @a1
			@ut.should_not be_valid
		end
		it "should not be valid without an application_id" do
			@ut = Utilization.new
			@ut.user_id = @u1
			@ut.should_not be_valid
		end

	end
	Utilization.all.each{|ut| ut.destroy}
end
