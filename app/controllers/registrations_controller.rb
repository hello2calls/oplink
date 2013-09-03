class RegistrationsController < Devise::RegistrationsController 
  def new
    flash[:alert] = "Sorry access can only be granted to admins!"
    redirect_to "/users/sign_in"
  end
end