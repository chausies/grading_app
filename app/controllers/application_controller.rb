class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
  include ApplicationHelper
	before_filter :assign_header_variables

	def assign_header_variables
		if signed_in? and current_user.courses.any? and current_user.enrollments.any?
			@amount = (current_user.enrollments.map { |e| e.gradings_to_do.count }).sum
		else
			@amount = 0
		end
	end
end
