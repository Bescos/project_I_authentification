require_relative 'spec_helper'


describe Application do
 it "sould not be valid without a name or an url" do
   subject.should_not be_valid
   a1 = Application.new 
   a1.name = 'testPresence'
   a1.should_not be_valid

   a2 = Application.new 
   a2.url = 'testPresence'
   a2.should_not be_valid
 end
 it "should not be valid if name already exists" do
  a1 = Application.new
  a1.name = 'testUniqueness'
  a1.url = 'http://testUniqueness'
  a1.save

  a2 = Application.new
  a2.name = 'testUniqueness'  
  a2.url = 'http://testUniqueness2' 
  a2.should_not be_valid
  Application.all.each{|a| a.destroy}
 end

 it "should not be valid if url already exists" do
  a1 = Application.new
  a1.name = 'testUniqueness'
  a1.url = 'http://testUniqueness'
  a1.save

  a2 = Application.new
  a2.name = 'testUniqueness2'  
  a2.url = 'http://testUniqueness' 
  a2.should_not be_valid
  Application.all.each{|a| a.destroy}
 end

end
