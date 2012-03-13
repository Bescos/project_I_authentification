require 'sinatra'
$: << File.join(File.dirname(__FILE__),"","middleware")

require 'digest/sha1'

$: << File.join(File.dirname(__FILE__),"")
require 'lib/user'
require 'lib/application'

require 'spec/spec_helper'

enable :sessions


helpers do 
  def current_user
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
  if @u.valid?
   @u.save
   session["current_user"] = params[:login]
   redirect "/users/#{params['login']}"
   #User invalide
  else
     if !User.find_by_login(@u.login).nil?
       @error_new = "User already exists"
       erb :"users/new"
     else 
       if params[:login]==""
         @error_new = "Empty login"
         erb :"users/new"
       else
         @error_new = "Incorrect password"
         erb :"users/new"
       end
     end
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
  #Récupération des champs du formulaire
  @u = User.find_by_login(params[:login])

  #Si  le user existe dans la base
  if @u!=nil and @u.password == Digest::SHA1.hexdigest(params[:password]).inspect
   session["current_user"] = params[:login]
   redirect "/users/#{params[:login]}"
  end 

  #Si le mot de passe est incorrect
  if @u==nil 
    @error_session = "User does not exists !"
    erb :"sessions/new"
  else if @u.password != Digest::SHA1.hexdigest(params[:password]).inspect
    @error_session = "Invalid password !"
    erb :"sessions/new"
       end
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
    a = Application.new
    a.name = params[:name]
    a.url = params[:url]
    a.user_id = params[:user_id]

    if a.valid? 
      a.save
      redirect "/applications/#{params[:name]}?secret=IamSAuth"
    else
      if !Application.find_by_name(a.name).nil?
        @error_application = "Application already exists !"
        erb :"applications/new"
      else 
         if !Application.find_by_url(a.url).nil?
            @error_application = "URL already exists !"
            erb :"applications/new"
         else 
           if a.name=='' or a.url==''
              @error_application = "Application name or URL empty"
              erb :"applications/new"
           end
         end
    	end
  	end
  else 
    @error_session = "Please connect first"
    erb :"sessions/new"
  end    
end

get '/applications/:name' do
  "Application #{:name} cree"
end


