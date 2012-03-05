require 'sinatra'
$: << File.join(File.dirname(__FILE__),"","middleware")
require 'my_middleware'

$: << File.join(File.dirname(__FILE__),"")
require 'lib/user'

require 'spec/spec_helper'

use RackCookieSession
use RackSession

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
get '/appli_cliente_1/sessions/new' do
  erb :"sessions/new"
end

#Si le login et le mot de passe passés en post correspondent à une ligne de la table users de la base de donnée, lutilisateur est redirigee vers lapplication et la page dorigine
#Sinon recharge le formulaire de connexion
post '/sessions' do
  params.inspect
  login = params[:login]
  password = params[:password]
  u = User.find_by_login(login)
  if u.password == password
    puts "OUAIIIIIIIIIIS"
  end 
end

