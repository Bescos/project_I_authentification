require 'sinatra'
$: << File.join(File.dirname(__FILE__),"","middleware")
require 'my_middleware'

use RackCookieSession
use RackSession
#use RackAuth

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
get '/sauth/appli_cliente1/sessions/new' do
  erb :"sessions/new"
end




