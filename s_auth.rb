require 'sinatra'
require 'active_record'

require 'digest/sha1'

require_relative 'database'
require_relative 'lib/user'
require_relative 'lib/application'
require_relative 'lib/utilization'

#enable :sessions

set :cookie_manager , Hash.new
def generate_cookie
  SecureRandom.base64
end

helpers do 
  def current_user
    cookie = request.cookies["sauthCookie"]
    if !cookie.nil?
      session["current_user"]=settings.cookie_manager[cookie]
    end
    session["current_user"]
  end

  def disconnect
    session["current_user"] = nil
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
	@u.city = params[:city]
	@u.email = params[:email]

  #Si le user est valide, on crée le user et on le redirige vers son profil
  if @u.save
   session["current_user"] = params[:login]
   redirect "/users/#{params['login']}"
   #User invalide
  else
     @errors = @u.errors.messages
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

			erb :"users/profil"
		else
			@errors="You don't have access rights for this page, please connect first !"
			erb :"sessions/new"
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
	if User.authentication(params)
	  login=params["login"]
    session["current_user"]=login
    cookie=generate_cookie
    settings.cookie_manager[cookie]=login
    response.set_cookie("sauthCookie",:value => cookie,:expires => Time.now+24*60*60) # 1 jour d'expiration
   
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
    @a.user_id = User.find_by_login(current_user)

    if @a.valid? 
      @a.save
      redirect "/applications/#{params[:name]}?secret=IamSAuth"
    else
      @errors = @a.errors.messages
      erb :"applications/new"
  	end
  else 
    @error_session = "Please connect first"
    erb :"sessions/new"
  end    
end

get '/applications/:name' do
  "Application #{params[:name]} cree"
end

get '/:appli/sessions/new' do
	if url_appli=Application.authentication(params[:appli])	
		@appli=params[:appli]
		@back_url=url_appli+params[:origin]
		erb :"sessions/appli"
	else 
		"The authentication service does not know the application called #{params[:appli]}"
	end
end

post '/:appli/sessions' do
	if User.authentication(params)
		user = User.find_by_login(params[:login])
		appl = Application.find_by_name(params[:appli])
		ut = Utilization.useappli?(user.id, appl.id)
		login=params["login"]
    session["current_user"]=login
    cookie=generate_cookie
    settings.cookie_manager[cookie]=login
    response.set_cookie("sauthCookie",:value => cookie,:expires => Time.now+24*60*60) # 1 jour d'expiration
		@back_url=params[:back_url]

		redirect "#{params[:back_url]}?login=#{params[:login]}&secret=IamSAuth"
	else
		@errors="Wrong authentication!"
		@appli=params[:appli]
  	erb :"sessions/appli"
  end
end


