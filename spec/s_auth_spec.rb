$: << File.dirname(__FILE__)
require 'spec_helper'

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
		params = {"user" => {'login'=>"TestAjout", 'password'=>"TestAjout"}}
    post '/users', params["user"]
    last_response.status.should == 302
    last_response.headers["Location"].should == 'http://example.org/users/TestAjout'
   end
   describe "Errors" do
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
    context "the authentication is ok" do
		 before(:each) do
			 params = {'login'=>"TestAjout", 'password'=>"TestAjout"}
       post '/sessions', params
		 end
		
		 it "should attribute a cookie to the user" do
			 last_response.headers["Set-Cookie"].should be_true
		 end
     it "should redirect the user to his profil because the login and password are ok" do
       last_response.status.should == 302
       last_response.headers["Location"].should == "http://example.org/users/TestAjout"
     end
     it "should store the login of the authenticated user" do
       last_request.env["rack.session"]["current_user"].should == "TestAjout"
     end
		 it "should display the user profile" do
			 get '/users/TestAjout',"","rack.session" => { "current_user" => "TestAjout" }
			 last_response.body.should match %r{<title>User-Profile Page</title>}
		 end
		 it "should list utilizations and developed applications of the user" do
			 user = double(User)
			 User.stub(:find_by_login){user}
			 User.should_receive(:find_by_login).with("TestAjout").and_return(user)
			 user.should_receive(:id)
			 
			 Application.should_receive(:find_all_by_user_id)
			 user.should_receive(:id)

			 get '/users/TestAjout',"","rack.session" => { "current_user" => "TestAjout" }
		 end
     it "should remove the variables of the current user when he disconnects" do
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
		it "should not display the user profile if the current_user doesn't match the :login in /users/:login" do
			 get '/users/TestAjout',"","rack.session" => { "current_user" => "false" }
			 last_response.body.should match %r{<form.*action="/sessions".*method="post".*}
			 last_response.body.should include "You don't have access rights for this page, please connect first !"
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
      describe "User connected and want to add an application" do
		    context "Validation of the post request" do
		      before(:each) do
						params2 = { 'name' => "appli_cliente_1", 'url' => "http://localhost:1800"} 
		        post '/applications', params2, "rack.session" => { "current_user" => "TestAjout" }
		      end

		      it "should respond with a secret" do
		        last_response.status.should == 302
		        last_response.headers["Location"].should include "http://example.org/applications/appli_cliente_1?secret="
		      end
					
		    end
		    
		    context "Errors" do
		      it "should send the application form again to the user because the name already exists" do
		        params = { 'name' => "appli_cliente_1", 'url' => "Erreur1"} 
		        post '/applications', params, "rack.session" => { "current_user" => "TestAjout" }
		        last_response.status.should == 200
		        last_response.body.should match %r{<form.*action="/applications".*method="post".*}
		      end
		      it "should send the application form again to the user because the url already exists" do
		        params = { 'name' => "Erreur2", 'url' => "http://localhost:1800"} 
		        post '/applications', params, "rack.session" => { "current_user" => "TestAjout" }
		        last_response.status.should == 200
		        last_response.body.should match %r{<form.*action="/applications".*method="post".*}
		      end
		      it "should send the application form again to the user because the name is empty" do
		        params = { 'name' => "", 'url' => "Erreur3"} 
		        post '/applications', params, "rack.session" => { "current_user" => "TestAjout" }
		        last_response.status.should == 200
		        last_response.body.should match %r{<form.*action="/applications".*method="post".*}
		      end
		      it "should send the application form again to the user because the url is empty" do
		        params = { 'name' => "Erreur4", 'url' => ""} 
		        post '/applications', params, "rack.session" => { "current_user" => "TestAjout" }
		        last_response.status.should == 200
		        last_response.body.should match %r{<form.*action="/applications".*method="post".*}
		      end
					it "should send the connetion form to the user because current_user is nil" do
						params = { 'name' => "appli_cliente_1", 'url' => "http://appli_cliente_1"}
						post '/applications', params, "rack.session" => { "current_user" => nil }
 						last_response.status.should == 200
						last_response.body.should match %r{<form.*action="/sessions".*method="post".*}
					end
		    end      
		    Application.all.each{|a| a.destroy}
				User.all.each{|u| u.destroy}
		  end
		end
	end
	describe "Thrid case: an application redirects the user to Sauth" do
		describe "get /appli/sessions/new" do
			it "should respond with the login form" do
				Application.should_receive(:authentication).with("appli_cliente_1").and_return("http://appli_cliente_1")
				get '/appli_cliente_1/sessions/new?origin=/protected' 
				last_response.should be_ok
				last_response.body.should match %r{<form.*action="/appli_cliente_1/sessions".*method="post".*}
				last_response.body.should match %r{<input id="session_back_url" name="back_url" size="50" type="hidden" value="http://appli_cliente_1/protected">}
			end
			it "should respond with the application register form if application is unknown" do
				get '/appli_cliente_2/sessions/new?origin=/protected' 
				last_response.should be_ok
			  last_response.body.should include "The authentication service does not know the application called appli_cliente_2"
			end
		end
		describe "post /appli/sessions/new" do
			describe "Redirection to the application" do
				it "should redirect the user to the back_url of the application" do
					params = {'login'=>"TestAjout", 'password'=>"TestAjout", 'back_url'=>"http://appli_cliente_1/protected"}
		      post '/appli_cliente_1/sessions', params
					last_response.status.should == 302
					#PB Lors du test, Le sinatra ne récupère pas @back_url. Cela fonctionne lors du test d'intégration
					last_response.headers["Location"].should include "http://appli_cliente_1/protected?login=TestAjout&secret="
				end
			end
			describe "Errors" do
				it "should send the authentication form again because password is wrong" do
					params = {'login'=>"TestAjout", 'password'=>"TestFaux"}
				  post '/appli_cliente_1/sessions', params
					last_response.status.should == 200
					last_response.body.should match %r{<form.*action="/appli_cliente_1/sessions".*method="post".*}
				end
			end
		end
	end 
	
	describe "Administration part" do
		describe "get /admin" do
			context "Admin rights" do
				before(:each) do
					get '/users/admin',"","rack.session" => { "current_user" => "admin" }
				end

				it "should display the administration page for the admin" do
					last_response.should be_ok
					last_response.body.should match %r{<p> Administration page </p>}
				end
				it "should list the users of the Sauth" do
					last_response.body.should match %r{<li>TestAjout</li>}
				end
			end
			context "Errors" do
				before(:each) do
					get '/users/admin',"","rack.session" => { "current_user" => "false" }
				end

				it "should redirect the user to the authentication page" do
					last_response.should be_ok
					last_response.body.should match %r{<h1>New session</h1>}
					last_response.body.should include "You don't have access rights for this page, please connect first !"
				end
			end
		end
	end
	
	describe "Root of the application" do
		describe "Non connected user" do
			it "should redirect te user to /sessions/new" do
				get '/'
				last_response.should be_redirect
				last_response.headers["Location"].should == "http://example.org/sessions/new"
			end
		end
		describe "Non connected user" do
			it "should redirect te user to /sessions/new" do
				get '/', '', "rack.session" => { "current_user" => "TestAjout" }
				last_response.should be_redirect
			  last_response.headers["Location"].should include "http://example.org/users/TestAjout"
			end
		end
	end

	describe "Application deletion" do
		it "should find the application" do
			appli = double(User)
			Application.should_receive(:find_by_name).and_return(appli)
			appli.should_receive(:destroy)
			post '/applications/appli_cliente_1/delete', '', "rack.session" => { "current_user" => "TestAjout" }
		end
		it "should redirect the user to his profile" do
			post '/applications/appli_cliente_1/delete', '', "rack.session" => { "current_user" => "TestAjout" }
			last_response.should be_redirect
			last_response.headers["Location"].should include "http://example.org/users/TestAjout"
		end
	end

	User.all.each{|u| u.destroy}
	Application.all.each{|a| a.destroy}
	Utilization.all.each{|ut| ut.destroy}
end

  

 
