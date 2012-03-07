$: << File.dirname(__FILE__)
require 'rack/test'
require_relative '../s_auth'

describe 'The Authentication App' do
 include Rack::Test::Methods

  def app
   Sinatra::Application
  end
  
  context "scenario 1: Utilisateur non connecte" do

   it "should respond with a form for the logging" do
    get '/s_auth/appli_cliente_1/sessions/new'
    last_response.should be_ok
    last_response.status.should == 200
    #to test if it respond the form, we test into a browser
   end

   context "the user is registered and try to connect" do
    it "should redirect the user to the application because the login and password are ok" do
     params = {'login'=>"toto", 'password'=>"toto"}
     post '/sessions', params
     last_response.status.should == 302
     last_response.headers["Location"].should == "http://example.org/appli_cliente1/protected"
    end
    it "should redirect the user to the login page with a warning message because the password is incorrect" do
     params = {'login'=>"toto", 'password'=>"bub"}
     post '/sessions', params
     last_response.status.should == 302
     last_response.headers["Location"].should == 'http://example.org/s_auth/appli_cliente_1/sessions/new?error=Identifiants_incorrects'
    end
   end

   context "the user is not registered and try to connect" do
    it "should redirect the user to the login page with a warning message" do
     post '/sessions', params={"login" => "tata", "password" => ""}
     last_response.status.should == 302
     last_response.headers["Location"].should == 'http://example.org/s_auth/appli_cliente_1/sessions/new?error=Identifiants_incorrects'
    end
   end

 end

  context "scenario2: Lutilisateur veut senregistrer" do
   it "should respond with a form for the registering" do
    get '/s_auth/appli_client_1/register'
    last_response.should be_ok
    last_response.status.should == 200
   end
   it "should redirect the user to the login page" do
    params = {'login'=>"TestAjout", 'password'=>"TestAjout"}
    post '/register', params
    last_response.status.should == 302
    last_response.headers["Location"].should == "http://example.org/s_auth/appli_cliente_1/sessions/new"
   end
  end

end
 
