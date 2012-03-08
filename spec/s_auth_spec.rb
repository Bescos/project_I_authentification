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
    get '/register'
    last_response.should be_ok
    last_response.status.should == 200
    #Taille de la page de register
    last_response.headers["Content-Length"].should == "1339"
   end
   it "should store the user and redirect him to the login page with a login message" do
    post '/register', params = {'login'=>"TestAjout", 'password'=>"TestAjout"}
    last_response.status.should == 302
    last_response.headers["Location"].should == 'http://example.org/sessions/new'
   end
   context "Erreurs" do
    it "should send the erb form again to the user with the wrong fields let empty" do
     post '/register', params = {'login'=>"TestAjout", 'password'=>"TestAjout"}
     last_response.status.should == 200
     #Taille de la page de register
     last_response.headers["Content-Length"].should == "1390"
    end
   end
  end

  context "Second case: User wants to connect" do

   it "should respond with a form for the logging" do
    get '/sessions/new'
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
     last_response.headers["Content-Length"].should == "716"
     last_response.status.should == 200
    end
   end

   context "the user is not registered and try to connect" do
    it "should redirect the user to the login page with a warning message" do
     post '/sessions', params={"login" => "Test", "password" => "TestAjout"}
     last_response.status.should == 200
     last_response.headers["Content-Length"].should == "665"
    end
   end
   #Destruction of the database
  User.all.each{|u| u.destroy}
  end
 end

  

 
