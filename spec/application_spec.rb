require_relative 'spec_helper'


describe Application do
 context "Test with 2 applications" do
  before(:each) do
    @a1 = Application.new 
    @a2 = Application.new 
    @a3 = Application.new
  end
  it "sould not be valid without a name, an url or an user_id" do
    subject.should_not be_valid
    @a1.url = 'http://testPresence'
    @a1.user_id = '1'
    @a1.should_not be_valid
    @a2.name = 'testPresence'
    @a2.user_id = '1'
    @a2.should_not be_valid
    @a3.url = 'http://testPresence'
    @a3.name = 'testPresence'
    @a3.should_not be_valid
  end
  context "Uniqueness of url and name" do
   before (:each) do
    @a1.name = 'testUniqueness'
    @a1.url = 'http://testUniqueness'
    @a1.user_id = '1'
    @a1.should be_valid
    @a1.save
   end
   it "should not be valid if name already exists" do
   @a2.name = 'testUniqueness'  
   @a2.url = 'http://testUniqueness2' 
   @a2.user_id = '2'
   @a2.should_not be_valid
   Application.all.each{|a| a.destroy}
   end

   it "should not be valid if url already exists" do
    @a2.name = 'testUniqueness2'  
    @a2.url = 'http://testUniqueness' 
    @a2.user_id = '2'
    @a2.should_not be_valid
    Application.all.each{|a| a.destroy}
   end
  end
  it "should not be valid with a non numeric user_id" do
   @a1.name = 'testUniqueness'
   @a1.url = 'http://testUniqueness'
   @a1.user_id = 'test'
   @a1.should_not be_valid
  end
 end
 

end
