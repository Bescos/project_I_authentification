$: << File.dirname(__FILE__)
require 'rack/test'
require_relative '../s_auth'

describe 'The Authentication App' do
 include Rack::Test::Methods

  def app
   Sinatra::Application
  end
  
  context "First case: User wants to register" do
   it "should respond with a form for the registering" do
    get '/s_auth/appli_cliente_1/register'
    last_response.should be_ok
    last_response.status.should == 200
   end
   it "should redirect the user to the login page with a login message" do
    post '/register', params = {'login'=>"TestAjout", 'password'=>"TestAjout"}
    last_response.status.should == 302
    last_response.headers["Location"].should == 'http://example.org/s_auth/appli_cliente_1/sessions/new?newuser=Bienvenue_vous_pouvez_maintenant_vous_connecter'
   end
   context "Erreurs" do
    it "should redirect the user to the register page with an error message because the login is already used" do
     post '/register', params = {'login'=>"TestAjout", 'password'=>"TestAjout"}
     last_response.status.should == 302
     last_response.headers["Location"].should == 'http://example.org/s_auth/appli_cliente_1/register?error=Login_deja_utilise'
    end
   end
  end

  context "Second case: User wants to connect" do

   it "should respond with a form for the logging" do
    get '/s_auth/appli_cliente_1/sessions/new'
    last_response.should be_ok
    last_response.status.should == 200
    #to test if it respond the form, we test into a browser
   end

   context "the user is registered and try to connect" do
    context "the authentication is ok" do
     it "should redirect the user to the application because the login and password are ok" do
      params = {'login'=>"TestAjout", 'password'=>"TestAjout"}
      post '/sessions', params
      last_response.status.should == 302
      last_response.headers["Location"].should == "http://example.org/appli_cliente1/protected"
     end
     it "should store the login of the authenticated user" do
      params = {'login'=>"TestAjout", 'password'=>"TestAjout"}
      post '/sessions', params
      last_request.env["rack.session"]["current_user"].should == "TestAjout"
      last_response.status.should == 302
     end
    it "should remove the variables of the current user when he disconnects" do
      params = {'login'=>"TestAjout", 'password'=>"TestAjout"}
      post '/sessions', params
      last_request.env["rack.session"]["current_user"].should == "TestAjout"
      last_response.status.should == 302
     end
    end
    it "should redirect the user to the login page with a warning message because the password is incorrect" do
     params = {'login'=>"TestAjout", 'password'=>"TestFaux"}
     post '/sessions', params
     last_response.status.should == 302
     last_response.headers["Location"].should == 'http://example.org/s_auth/appli_cliente_1/sessions/new?error=Identifiants_incorrects'
    end
   end

   context "the user is not registered and try to connect" do
    it "should redirect the user to the login page with a warning message" do
     post '/sessions', params={"login" => "Test", "password" => "TestAjout"}
     last_response.status.should == 302
     last_response.headers["Location"].should == 'http://example.org/s_auth/appli_cliente_1/sessions/new?error=Identifiants_incorrects'
    end
   end
   #Destruction of the database
  User.all.each{|u| u.destroy}
  end
 end

  

 
