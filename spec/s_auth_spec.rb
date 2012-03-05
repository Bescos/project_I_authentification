$: << File.dirname(__FILE__)
require 'rack/test'
require_relative '../s_auth'

describe 'The Authentication App' do
 include Rack::Test::Methods

  def app
   Sinatra::Application
  end
  
  context "scenario 1: Utilisateur non connecte" do
   it "send a link for authenticate the new user" do
    get '/'
    last_response.should be_ok
   end

   it "respond with a form for the application" do
    get '/appli_cliente_1/sessions/new'
    last_response.should be_ok
    last_response.status.should == 200
    #to test if it respond the form, we test into a browser
  end

  it "should redirect the user to the application" do
   post '/sessions', params={login => 'toto', password => 'bob'}
   last_response.should be_ok
   last_response.status.should == 302
  end

end
 
