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


#La page protégée de l'application est affichée que si l'utilisateur est enregistré et logué 
get '/appli_cliente1/protected' do
  if current_user
    erb :protected, :locals => {:user => current_user}
  else
    #redirection vers la page de login avec sauvegarde de l'application demandée dans origine
    redirect '/sauth/appli_cliente1/sessions/new?origine=/protected'
  end
end


get '/s_auth/appli_cliente_1/register' do
  msg_error = params[:error]
  erb :"register", :locals => {:error => msg_error}
end

post '/register' do
  u = User.new
  u.login = params[:login]
  u.password = params[:password]
  u.last_name = params[:last_name]
  u.first_name = params[:first_name]
  u.city = params[:city]
  u.email = params[:email]
  
  #Si les champs login et mot de passe ne sont pas renseignés, on redirige l'utilisateur vers le formulaire d'enregistrement avec un message d'erreur
  if u.login == nil or u.password == nil
    redirect '/s_auth/appli_cliente_1/register?error=Login_ou_mot_de_passe_non_renseigne' 
  else
  #Si les champs login et mot de passe sont renseignés, on teste l'enregistrement dans la base de données
      #Si le user est valide, on crée le user et on le redirige vers le formulaire d'authentification
      if u.valid?
        u.save
        redirect '/s_auth/appli_cliente_1/sessions/new?newuser=Bienvenue_vous_pouvez_maintenant_vous_connecter'
      #User invalide
      else
       #Si le login existe, on redirige l'utilisateur vers le formulaire d'enregistrement avec un message d'erreur
       if User.find_by_login(u.login) != nil
         redirect '/s_auth/appli_cliente_1/register?error=Login_deja_utilise' 
       #Non respect des conditions de remplissage des champs du login 
       else
         redirect '/s_auth/appli_cliente_1/register?error=Erreur_dans_le_remplissage_des_champs' 
       end
      end
  end
end



#Charge le template erb pour une nouvelle connexion
get '/s_auth/appli_cliente_1/sessions/new' do
  msg_logging = params[:newuser]
  msg_error = params[:error]
  erb :"sessions/new", :locals => {:newuser => msg_logging,:error => msg_error}
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


get '/sessions/disconnect' do
  session["current_user"] = nil
  erb :"sessions/new" 
end



