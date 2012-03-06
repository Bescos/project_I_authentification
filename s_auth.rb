require 'sinatra'
$: << File.join(File.dirname(__FILE__),"","middleware")
require 'my_middleware'

$: << File.join(File.dirname(__FILE__),"")
require 'lib/user'

require 'spec/spec_helper'

#use RackCookieSession
#use RackSession

helpers do 
  def current_user
    session["current_user"]
  end

  def disconnect
    session["current_user"] = nil
  end
end



#La page protégée de l'application est affichée que si l'utilisateur est enregistré et logué 
get '/appli_cliente1/protected' do
  if current_user
    erb :protected, :locals => {:user => current_user}
  else
    #redirection vers la page de login avec sauvegarde de l'application demandée dans origine
    redirect '/sauth/appli_cliente1/sessions/new?origine=/protected'
  end
end

#Charge le template erb pour une nouvelle connexion
get '/s_auth/appli_cliente_1/sessions/new' do
  msg_error = params[:error]
  erb :"sessions/new", :locals => {:error => msg_error}
end

#Si le login et le mot de passe passés en post correspondent à une ligne de la table users de la base de donnée, lutilisateur est redirigee vers lapplication et la page dorigine
#Sinon recharge le formulaire de connexion
post '/sessions' do
   #Récupération des champs du formulaire
  params.inspect
  login = params[:login]
  password = params[:password]
  u = nil
  u = User.find_by_login(login)

  #Si  le user existe dans la base
  if u!=nil and u.password == password
   redirect '/appli_cliente1/protected'
  end 

  #Si le mot de passe est incorrect
  if u!=nil and u.password != password
    redirect '/s_auth/appli_cliente_1/sessions/new?error=Identifiants_incorrects'
    puts 'password faux'
  end

  #Si le user n'existe pas dans la base
  if u==nil
    redirect '/s_auth/appli_cliente_1/sessions/new?error=Identifiants_incorrects'
  end
  
end

