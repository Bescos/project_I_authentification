$: << File.dirname(__FILE__)
require 'sinatra_auth'
require 'rack/test'

describe 'The Authentication App' do
 include Rack::Test::Methods

  def app
   Sinatra::Application
  end

  it "send a link for authenticate the new user" do
   get '/'
   last_response.should be_ok
   last_response.body.should == '<a href="/sessions/new">Login</a>'
  end
  
  

end
 
