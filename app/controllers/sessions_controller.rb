class SessionsController < ApplicationController

	def new
	end

	def create
		user = User.find_by(email: params[:session][:email].downcase)
		if !user
			flash.now[:error] = 'This email is not registered'
		elsif !user.authenticate(params[:session][:password])
			flash.now[:error] = 'Invalid password'
		else
	    	sign_in user
      		redirect_back_or user
	  	end
	end

	def destroy
		sign_out
		redirect_to root_url
	end

end
