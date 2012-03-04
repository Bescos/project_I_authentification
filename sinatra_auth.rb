require 'sinatra'
$: << File.join(File.dirname(__FILE__),"","middleware")
require 'my_middleware'

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


get '/' do
#Lien vers le formulaire de connexion dans le cas d'un nouvel utilisateur
#Sinon Afficher Bonjour User
  if current_user
    "Bonjour #{current_user}"
  else
    '<a href="/sessions/new">Login</a>'
  end
end


