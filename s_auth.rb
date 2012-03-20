require 'sinatra'
require 'active_record'
require 'logger'
require 'digest/sha1'

require_relative 'database'
require_relative 'lib/user'
require_relative 'lib/application'
require_relative 'lib/utilization'

enable :sessions

set :logger , Logger.new('log/log_sessions.txt', 'weekly')

helpers do 
  def current_user
    session["current_user"]
  end

  def disconnect
    session["current_user"] = nil
  end
end

get '/' do
	if current_user
		redirect "/users/#{current_user}"
	else
		redirect '/sessions/new'
	end
end

#Renvois le formulaire de création d'un utilisateur
get '/users/new' do
  erb :"users/new", :locals => {:user => nil, :error => nil}
end


#Crée un utilisateur s'il est valide et redirige le user vers sa page de profil ou vers le meme formulaire en cas d'erreur
post '/users' do
  @u = User.new
	@u.login = params[:login]
	@u.password = params[:password]
	@u.last_name = params[:last_name]
	@u.first_name = params[:first_name]
	@u.email = params[:email]
	@u.city = params[:city]

  #Si le user est valide, on crée le user et on le redirige vers son profil
  if @u.save
   session["current_user"] = params[:login]
   redirect "/users/#{params['login']}"
   #User invalide
  else
    # @errors = @u.errors.messages
		 erb :"users/new"
  end
end


#Profil d'un utilisateur
get "/users/:login" do
	if session["current_user"]=="admin"
		@users = []
		User.all.each do |user|
			@users.push(user)
		end

  	erb :"users/admin"
	else
		if session["current_user"]==params[:login]
			@user=User.find_by_login(params[:login])
			
			@apps = []			
			uses = Utilization.where(:user_id => @user.id)
			uses.each do |use|
				@apps.push(Application.find_by_id(use.application_id))
			end

			@devs = []
			@devs = Application.find_all_by_user_id(@user.id)

			if params[:secret]
				@secret=params[:secret]
			end
			erb :"users/profil"
		else
			@errors="You don't have access rights for this page, please connect first !"
			erb :"/sessions/new"
		end
	end
end


#Renvois le template de nouvelle connexion
get '/sessions/new' do
  erb :"sessions/new", :locals => {:user => nil, :error => nil}
end


#Si le login et le mot de passe passés en post correspondent à une ligne de la table users de la base de donnée, lutilisateur est redirigee vers son profil ou lapplication dorigine
#Sinon recharge le formulaire de connexion
post '/sessions' do
	settings.logger.info("post /sessions => "+params["login"])
	if User.authentication(params)
	 login=params["login"]
   session["current_user"]=login
   
   redirect "/users/#{params[:login]}"
  else
		@errors="Wrong authentication!"
  	erb :"sessions/new"
  end

end


#Efface les informations associées à la session de l'utilisateur et le redirige vers la page de login
get '/sessions/disconnect' do
  session["current_user"] = nil
  erb :"sessions/new", :locals => {:user => nil, :error => nil}
end


#Renvois le formulaire de création d'une application
get '/applications/new' do
  erb :"applications/new"
end

post '/applications' do  
  if current_user
    @a = Application.new
    @a.name = params[:name]
    @a.url = params[:url]
    @a.user_id = User.find_by_login(session["current_user"]).id
		
    if @a.save
      redirect "/users/#{current_user}?secret=IamSAuth"
    else
      @errors = @a.errors.messages
      erb :"applications/new"
  	end
  else 
    @errors = "Please connect first"
    erb :"sessions/new"
  end    
end


post '/applications/:name/delete' do
	app = Application.find_by_name(params[:name])
	app.destroy
	redirect "/users/#{current_user}"	
end

get '/:appli/sessions/new' do
		if url_appli=Application.authentication(params[:appli])	
		  @appli=params[:appli]
			@back_url=url_appli+params[:origin]
			if current_user
				user = User.find_by_login(current_user)
				appl = Application.find_by_name(params[:appli])
				if !Utilization.find_by_user_id_and_application_id(user.id,appl.id)
					u = Utilization.new
					u.user_id = user.id
					u.application_id = appl.id
					u.save
			  end
				redirect "#{@back_url}?login=#{current_user}&secret=IamSAuth"
			else
				erb :"sessions/appli"
			end
		else 
			"The authentication service does not know the application called #{params[:appli]}"
		end
end

post '/:appli/sessions' do
		settings.logger.info("post /sessions => "+params["login"])
		if User.authentication(params)
			user = User.find_by_login(params[:login])
			appl = Application.find_by_name(params[:appli])

		  if !Utilization.find_by_user_id_and_application_id(user.id,appl.id)
				u = Utilization.new
				u.user_id = user.id
				u.application_id = appl.id
				u.save
			end
			login=params["login"]
		  session["current_user"]=login
			@back_url=params[:back_url]

			redirect "#{params[:back_url]}?login=#{params[:login]}&secret=IamSAuth"
		else
			@errors="Wrong authentication!"
			@appli=params[:appli]
			erb :"sessions/appli"
		end
end
