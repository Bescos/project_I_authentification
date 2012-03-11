require 'sinatra'
$: << File.join(File.dirname(__FILE__),"","middleware")
require 'my_middleware'
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
  erb :"users/new", :locals => {:user => nil}
end


#Crée un utilisateur s'il est valide et redirige le user vers sa page de profil ou vers le meme formulaire en cas d'erreur
post '/users' do
  u = User.new
  u.login = params[:login]
  u.password = params[:password]
  u.last_name = params[:last_name]
  u.first_name = params[:first_name]
  u.city = params[:city]
  u.email = params[:email]
  
  #Si le user est valide, on crée le user et on le redirige vers son profil
  if u.valid?
   u.save
   redirect "/users/#{params['login']}"
   #User invalide
  else
     erb :"users/new", :locals => {:user => u}
  end
end


#Profil d'un utilisateur
get "/users/:login" do
  "bonjour #{login}"
end


#Renvois le template de nouvelle connexion
get '/sessions/new' do
  erb :"sessions/new", :locals => {:user => nil}
end


#Si le login et le mot de passe passés en post correspondent à une ligne de la table users de la base de donnée, lutilisateur est redirigee vers son profil ou lapplication dorigine
#Sinon recharge le formulaire de connexion
post '/sessions' do
  #Récupération des champs du formulaire
  u = User.find_by_login(params[:login])

  #Si  le user existe dans la base
  if u!=nil and u.password == Digest::SHA1.hexdigest(params[:password]).inspect
   session["current_user"] = params[:login]
   redirect "/sessions/#{params[:login]}"
  end 

  #Si le mot de passe est incorrect
  if u==nil or u.password != Digest::SHA1.hexdigest(params[:password]).inspect
    erb :"sessions/new", :locals => {:user => u}
  end

end


#Efface les informations associées à la session de l'utilisateur et le redirige vers la page de login
get '/sessions/disconnect' do
  session["current_user"] = nil
  erb :"sessions/new", :locals => {:user => u}
end


#Renvois le formulaire de création d'une application
get '/applications/new' do
  erb :"applications/new"
end

post '/applications' do
  a = Application.create(params[:name], params[:url])
  if a 
    redirect "/applications/#{params['name']}"
  else
    erb :"applications/new"
  end
end


