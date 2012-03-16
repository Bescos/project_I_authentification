require 'sinatra'
$: << File.join(File.dirname(__FILE__),"","middleware")

require 'digest/sha1'

$: << File.join(File.dirname(__FILE__),"")

require 'spec/spec_helper'

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
  @u = User.new(params)
 
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
  #"bonjour #{params[:login]}"
  erb :"users/profil", :locals => {:login => params[:login]}
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
  "Application #{:name} cree"
end


