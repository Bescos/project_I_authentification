$: << File.dirname(__FILE__)
require 'rack/test'
require_relative '../s_auth'

describe 'The Authentication App' do
 include Rack::Test::Methods

  def app
   Sinatra::Application
  end
  
  describe "First case: User wants to register" do
   it "should respond with a form for the registering" do
    get '/users/new'
    last_response.should be_ok
    last_response.status.should == 200
    last_response.body.should match %r{<form.*action="/users".*method="post".*}
   end
   it "should store the user and redirect him to the login page with a login message" do
    post '/users', params = {'login'=>"TestAjout", 'password'=>"TestAjout"}
    last_response.status.should == 302
    last_response.headers["Location"].should == 'http://example.org/users/TestAjout'
   end
   describe "Erreurs" do
    it "should send the erb form again to the user because the login already exists" do
     post '/users', params = {'login'=>"TestAjout", 'password'=>"TestAjout"}
     last_response.status.should == 200
     last_response.body.should match %r{<form.*action="/users".*method="post".*}
    end
    it "should send the erb form again to the user because login is empty" do
     post '/users', params = {'login'=>"", 'password'=>"TestAjout"}
     last_response.status.should == 200
     last_response.body.should match %r{<form.*action="/users".*method="post".*}
    end
    it "should send the erb form again to the user because password is empty" do
     post '/users', params = {'login'=>"TestAjout", 'password'=>""}
     last_response.status.should == 200
     last_response.body.should match %r{<form.*action="/users".*method="post".*}
    end
   end
  end

  describe "Second case: User wants to connect" do

   it "should respond with a form for the logging" do
    get '/sessions/new'
    last_response.should be_ok
    last_response.body.should match %r{<form.*action="/sessions".*method="post".*}
   end

   describe "the user is registered and try to connect" do
    describe "the authentication is ok" do
     it "should redirect the user to his profil because the login and password are ok" do
      params = {'login'=>"TestAjout", 'password'=>"TestAjout"}
      post '/sessions', params
      last_response.status.should == 302
      last_response.headers["Location"].should == "http://example.org/users/TestAjout"
     end
     it "should store the login of the authenticated user" do
      params = {'login'=>"TestAjout", 'password'=>"TestAjout"}
      post '/sessions', params
      last_request.env["rack.session"]["current_user"].should == "TestAjout"
     end
    it "should remove the variables of the current user when he disconnects" do
      params = {'login'=>"TestAjout", 'password'=>"TestAjout"}
      post '/sessions', params
      last_request.env["rack.session"]["current_user"].should == "TestAjout"
      get '/sessions/disconnect'
      last_request.env["rack.session"]["current_user"].should be_nil
     end
    end
   end
   describe "Errors" do
    it "should redirect the user to the login page with a warning message because login does not exist" do
     post '/sessions', params={"login" => "Test", "password" => "TestAjout"}
     last_response.status.should == 200
    end
    it "should redirect the user to the login page with a warning message because the password is incorrect" do
     params = {'login'=>"TestAjout", 'password'=>"TestFaux"}
     post '/sessions', params
     last_response.status.should == 200
     last_response.body.should match %r{<form.*action="/sessions".*method="post".*}
    end
    it "should redirect the user to the login page with a warning message because the login is empty" do
     params = {'login'=>"", 'password'=>"TestFaux"}
     post '/sessions', params
     last_response.status.should == 200
     last_response.body.should match %r{<form.*action="/sessions".*method="post".*}
    end
    it "should redirect the user to the login page with a warning message because the password is empty" do
     params = {'login'=>"TestAjout", 'password'=>""}
     post '/sessions', params
     last_response.status.should == 200
     last_response.body.should match %r{<form.*action="/sessions".*method="post".*}
    end
   end
   #Destruction of the database
  User.all.each{|u| u.destroy}
  end

  describe "Application registration" do
    describe "get /applications/new" do
      it "should return a form to post register our application" do
        get '/applications/new'
        last_response.should be_ok
        last_response.body.should match %r{<form.*action="/applications".*method="post".*}
      end
    end
    describe "post /applications" do
      context "User connected and want to add an application" do
		    before(:each) do
	 				post '/users', {'login' => "toto", 'password' => "toto"}
		    end
        after(:each) do
          User.all.each{|u| u.destroy}
        end

		    params = { 'name' => "appli_cliente_1", 'url' => "http://appli_cliente_1", 'user_id' => '1'} 
		        
		    context "Validation of the post request" do
		      before(:each) do
		        appli = double(:application)
		        post '/applications', params
		      end

		      it "should respond with a secret" do
		        last_response.status.should == 302
		        last_response.headers["Location"].should == "http://example.org/applications/appli_cliente_1?secret=IamSAuth"
		      end
		    end
		    
		    context "Errors" do
		      it "should send the application form again to the user because the name already exists" do
		        params = { 'name' => "appli_cliente_1", 'url' => "Erreur1", 'user_id' => '1'} 
		        post '/applications', params
		        last_response.status.should == 200
		        last_response.body.should match %r{<form.*action="/applications".*method="post".*}
		      end
		      it "should send the application form again to the user because the url already exists" do
		        params = { 'name' => "Erreur2", 'url' => "http://appli_cliente_1", 'user_id' => '1'} 
		        post '/applications', params
		        last_response.status.should == 200
		        last_response.body.should match %r{<form.*action="/applications".*method="post".*}
		      end
		      it "should send the application form again to the user because the name is empty" do
		        params = { 'name' => "", 'url' => "Erreur3", 'user_id' => '1'} 
		        post '/applications', params
		        last_response.status.should == 200
		        last_response.body.should match %r{<form.*action="/applications".*method="post".*}
		      end
		      it "should send the application form again to the user because the url is empty" do
		        params = { 'name' => "Erreur4", 'url' => "", 'user_id' => '1'} 
		        post '/applications', params
		        last_response.status.should == 200
		        last_response.body.should match %r{<form.*action="/applications".*method="post".*}
		      end
		    end 
		    #Destruction of the database       
		    Application.all.each{|a| a.destroy}
		 end
		 end
		end
 end

  

 
