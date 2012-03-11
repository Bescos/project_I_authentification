require 'sinatra'
$: << File.join(File.dirname(__FILE__),"","middleware")
require 'my_middleware'
require 'digest/sha1'

$: << File.join(File.dirname(__FILE__),"")
require 'lib/user'

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

["appli_cliente_1", "/appli_client_2"].each do |applications|


#La page protégée de l'application est affichée que si l'utilisateur est enregistré et logué 
get '/s_auth/protected' do
  if current_user
    erb :protected, :locals => {:user => current_user}
  else
    #redirection vers la page de login avec sauvegarde de l'application demandée dans origine
    redirect '/sauth/appli_cliente_1/sessions/new?origine=/protected'
  end
end

get '/users/new' do
  erb :"users/new", :locals => {:user => nil}
end

post '/users' do
  u = User.new
  u.login = params[:login]
  u.password = params[:password]
  u.last_name = params[:last_name]
  u.first_name = params[:first_name]
  u.city = params[:city]
  u.email = params[:email]
  

  #Si le user est valide, on crée le user et on le redirige vers le formulaire d'authentification
  if u.valid?
   u.save
   redirect '/sessions/new'
   #User invalide
  else
     erb :"users/new", :locals => {:user => u}
  end
end



#Charge le template erb pour une nouvelle connexion
get '/sessions/new' do
  erb :"sessions/new", :locals => {:user => nil}
end


#Si le login et le mot de passe passés en post correspondent à une ligne de la table users de la base de donnée, lutilisateur est redirigee vers lapplication et la page dorigine
#Sinon recharge le formulaire de connexion
post '/sessions' do
  #Récupération des champs du formulaire
  login = params[:login]
  password = params[:password]
  u = nil
  u = User.find_by_login(login)

  #Si  le user existe dans la base
  if u!=nil and u.password == Digest::SHA1.hexdigest(password).inspect
   session["current_user"] = login
   redirect "/sessions/#{params['login']}"
  end 

  #Si le mot de passe est incorrect
  if u==nil or u.password != Digest::SHA1.hexdigest(password).inspect
    erb :"sessions/new", :locals => {:user => u}
  end

end


get '/sessions/disconnect' do
  session["current_user"] = nil
  erb :"sessions/new", :locals => {:user => u}
end

end

