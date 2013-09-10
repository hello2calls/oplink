class ApplicationController < ActionController::Base
  protect_from_forgery
  def setStatus(customer)
	opus = Opu.all
	act = false
	opus.each do |opu|
	  if opu.status == "Active"
	  	act = true
	  	break
	  else
	  	act = false
	  end
	end
	if act == true
		customer.status = "Active"
	else
		customer.status = "Not Active"
	end
	customer.save
  end

  rescue_from CanCan::AccessDenied do |exception|
	  flash[:alert] = "Access restricted to admins only!"
	  redirect_to root_url
  end
  rescue_from ActiveRecord::RecordNotFound do |exception|
  	flash[:alert] = "Record does not exist!"
	redirect_to root_url
  end
end
