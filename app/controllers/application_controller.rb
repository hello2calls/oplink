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

  def csvify(object, options={})
  	CSV.generate(options) do |csv|
  	column_names = ["first", "last", "phone", "email", "balance", "country"]
    csv << column_names
    object.each do |obj|
      csv << obj.attributes.values_at(*column_names)
    end
  end
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
