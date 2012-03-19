$: << File.dirname(__FILE__)

require_relative '../appli_cliente_1'


require 'rspec'
require 'rack/test'


describe 'The Authentication App' do
 include Rack::Test::Methods

  def app
   Sinatra::Application
  end
  
  describe "get /protected" do
		describe "Authentication is OK" do
			it "should redirect the user to SAuth" do
				get '/protected'
				last_response.should be_redirect
				last_response.headers["Location"].should == "http://localhost:4567/appli_cliente_1/sessions/new?origin=/protected"
			
			end
			it "should store the login of the user into the session env" do
				get '/protected?login=TestAjout&secret=IamSAuth'
				last_request.env["rack.session"]["current_user"].should == "TestAjout"
			end
		end
		describe "Errors" do
   		it "should display a problem" do
				get '/protected?login=TestAjout&secret=IamFake'
				last_response.body.should include "Authentication Problem !"
			end
		end
	end

end
