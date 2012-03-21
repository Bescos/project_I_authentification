require 'sinatra'
require 'active_record'
require 'logger'
require 'digest/sha1'

require_relative 'database'
require_relative 'lib/user'
require_relative 'lib/application'
require_relative 'lib/utilization'

enable :sessions

set :logger , Logger.new('log/log_sessions.txt', 'weekly')

helpers do 
  def current_user
    session["current_user"]
  end

  def disconnect
    session["current_user"] = nil
  end
end

get '/' do
	if current_user
		redirect "/users/#{current_user}"
	else
		redirect '/sessions/new'
	end
end

#Get the user creation form
get '/users/new' do
  erb :"users/new", :locals => {:user => nil, :error => nil}
end


#Creates the user and redirects him if it goes well or reload the form with errors
post '/users' do
  @u = User.new
	@u.login = params[:login]
	@u.password = params[:password]
	@u.last_name = params[:last_name]
	@u.first_name = params[:first_name]
	@u.email = params[:email]
	@u.city = params[:city]

  if @u.save
   session["current_user"] = params[:login]
   redirect "/users/#{params['login']}"
  else
		 erb :"users/new"
  end
end


#Load user profile or admin profile
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

			if params[:secret]
				@secret=params[:secret]
			end
			erb :"users/profil"
		else
			@errors="You don't have access rights for this page, please connect first !"
			erb :"/sessions/new"
		end
	end
end


#Load the connexion template
get '/sessions/new' do
  erb :"sessions/new", :locals => {:user => nil, :error => nil}
end


#if login is OK, the user is redirected to his profile
#Else reload the form with errors
post '/sessions' do
	settings.logger.info("post /sessions => "+params["login"])
	if User.authentication(params)
	 login=params["login"]
   session["current_user"]=login
   
   redirect "/users/#{params[:login]}"
  else
		@errors="Wrong authentication!"
  	erb :"sessions/new"
  end

end


#Disconnect the user, erase his session
get '/sessions/disconnect' do
  session["current_user"] = nil
  erb :"sessions/new", :locals => {:user => nil, :error => nil}
end


#Load the creation application form
get '/applications/new' do
  erb :"applications/new"
end

#Create an application if name and url are good and if there is a current_user
#Or reload the form with errors
post '/applications' do  
  if current_user
    @a = Application.new
    @a.name = params[:name]
    @a.url = params[:url]
    @a.user_id = User.find_by_login(session["current_user"]).id
		
    if @a.save
      redirect "/users/#{current_user}?secret=IamSAuth"
    else
      @errors = @a.errors.messages
      erb :"applications/new"
  	end
  else 
    @errors = "Please connect first"
    erb :"sessions/new"
  end    
end

#Delete the application to the database
post '/applications/:name/delete' do
	app = Application.find_by_name(params[:name])
	app.destroy
	redirect "/users/#{current_user}"	
end

#Get the login form from an application (it stores back_url in the form)
get '/:appli/sessions/new' do
		if url_appli=Application.authentication(params[:appli])	
		  @appli=params[:appli]
			@back_url=url_appli+params[:origin]
			if current_user
				user = User.find_by_login(current_user)
				appl = Application.find_by_name(params[:appli])
				if !Utilization.find_by_user_id_and_application_id(user.id,appl.id)
					u = Utilization.new
					u.user_id = user.id
					u.application_id = appl.id
					u.save
			  end
				redirect "#{@back_url}?login=#{current_user}&secret=IamSAuth"
			else
				erb :"sessions/appli"
			end
		else 
			"The authentication service does not know the application called #{params[:appli]}"
		end
end

#if login is OK, the user is redirected to the application origin url
#Else reload the form with errors
post '/:appli/sessions' do
		settings.logger.info("post /sessions => "+params["login"])
		if User.authentication(params)
			user = User.find_by_login(params[:login])
			appl = Application.find_by_name(params[:appli])

		  if !Utilization.find_by_user_id_and_application_id(user.id,appl.id)
				u = Utilization.new
				u.user_id = user.id
				u.application_id = appl.id
				u.save
			end
			login=params["login"]
		  session["current_user"]=login
			@back_url=params[:back_url]

			redirect "#{params[:back_url]}?login=#{params[:login]}&secret=IamSAuth"
		else
			@errors="Wrong authentication!"
			@appli=params[:appli]
			erb :"sessions/appli"
		end
end
