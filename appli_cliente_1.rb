require 'sinatra'

set :port, 1800
enable :sessions

helpers do 
	def secret
		secret="IamSAuth"
	end
	def current_user
    session["current_user"]
  end
end

get '/protected' do
	if params[:secret] && params[:login]
			if secret == params[:secret]
				session["current_user"]=params[:login]
				"Protected"
			else 
				"Authentication Problem !"
			end
	else
		redirect 'http://localhost:4567/appli_cliente_1/sessions/new?origin=/protected'
	end
end

