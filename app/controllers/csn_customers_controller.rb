require 'rufus/scheduler'
class CsnCustomersController < ApplicationController
  respond_to :json
  SCHEDULER = Rufus::Scheduler.start_new
  def getCustomer
  	if params[:token]
      if params[:token] == "uewyiyutywegfysdvcj"
        customer = Customer.find(params[:user_id].to_i)
        #user = CsnCustomer.new(params[:user])
        if customer
            render :json => {message: "Success", info: customer}
        else
          render :json => {:error => "Could not locate this user!"}
        end
      else
        render :json => { :error => "Invalid credentials" }, :status => 401
      end
    else
      render :json => { :error => "Invalid request" }, :status => 400
    end
  end

  def addPayment
    if params[:token]
      if params[:token] == "uewyiyutywegfysdvcj"
        customer = Customer.find(params[:user_id]) rescue nil
        if customer
            payment = Payment.new()
            payment.customer_id = params[:user_id].to_i
            payment.amount = params[:amount]
            payment.opu_sn = params[:sn]
            payment.date = Time.now
            if payment.save
              opu = Opu.find_by_sn(payment.opu_sn)
              #code for making sure the activation request went through
              savon_client = Savon::Client.new("http://c4miws.elasticbeanstalk.com/services/C4miForCiaoWebServiceImpl?wsdl")
              session[:auth] = "C4miforciao2013"
              session[:phone] = customer.phone
              session[:opu] = payment.opu_sn
              #@response = savon_client.request :web, :activate, body: {auth: "C4miforciao2013", phoneNum: "2434325434534", opuSn: "10110000C83A3531D808", enableService: "1"}
              @response = savon_client.request :web, :activate, body: {auth: session[:auth], phoneNum: session[:phone], opuSn: session[:opu], enableService: "1"}
              @message = ActiveSupport::JSON.decode(@response.to_hash[:activate_response][:activate_return].gsub(/:([a-zA-z])/,'\\1'))
              if @message["success"] == "true"
                if payment.save
                  customer.status = "Active"
                  opu.status = "Active"
                  opu.activation_date = Time.now
                  opu.expiration_date = Time.now + 1.month
                  opu.save
                  #set the expiration date to be one month from now
                  SCHEDULER.at('#{Time.now + 1.month}') do
                    @response2= savon_client.request :web, :deactivate, body: {auth: session[:auth], phoneNum: session[:phone], opuSn: session[:opu], enableService: "0"}
                    @message2 = ActieSupport::JSON.decode(@response2.to_hash[:deactivate_response][:deactivate_return].gsub(/:([a-zA-z])/,'\\1'))
                    if @message2["success"] == "true"
                        customer.status = "Not Active"
                    else
                      flash[:alert] = "Could not deactivate customer, #{@message['message']}"
                    end
                    #TO DO
                    #email if the deactivation is not successful
                  end
                  customer.save
                  flash[:notice] = "Activation successful!"
                else
                  flash[:alert] = "Coul not activate the opu!"
                end
              elsif @message["success"] == "false"
                flash[:alert] = "Could not activate, #{@message['message']}"
              end

              render :json => {:message => "Payment Successful for customer #{customer.first} #{customer.last}"}
            else
              render :json => {:error => "Failure"}
            end
        else
          render :json => {:error => "Could not locate this Customer!"}
        end
      else
        render :json => { :error => "Invalid credentials" }, :status => 401
      end
    else
      render :json => { :error => "Invalid request" }, :status => 400
    end
  end

  def addCustomer
    if params[:token]
      if params[:token] == "uewyiyutywegfysdvcj"
        #user = CsnCustomer.new(params[:user])
        customer = Customer.new()
        customer.activation_date = Time.now()
        customer.status = "Not active"
        customer.first = params[:first]
        customer.last = params[:last]
        customer.country = params[:country]
        customer.phone = params[:phone]
        customer.email = params[:email]
        customer.balance = 0.0
        if customer.save
            render :json => {:message => "Customer #{customer.first} #{customer.last} was successfully created! User id is #{customer.id}"}
        else
          render :json => {:error => customer.errors}
        end
      else
        render :json => { :error => "Invalid credentials" }, :status => 401
      end
    else
      render :json => { :error => "Invalid request" }, :status => 400
    end
  end

  def addOpu
    if params[:token]
        if params[:token] == "uewyiyutywegfysdvcj"
          opu = Opu.new()
          opu.status = "Not active"
          first = params[:first]
          last = params[:last]
          @customer = Customer.where(first: first, last: last) rescue nil
          if not @customer.empty?
            opu.customer_id = @customer.first[:id] rescue nil
            opu.sn = params[:sn]
            if opu.save
              render :json => {:message => "opu for #{@customer.first[:first]} #{@customer.first[:last]} was successfully created!"}
            else
              render :json => {:error => opu.errors}
            end
          else
            render :json => {:error => "This cutomer doesn't exist!"}
          end
        else
          render :json => { :error => "Invalid credentials" }, :status => 401
        end
    else
      render :json => { :error => "Invalid request" }, :status => 400
    end
  end
end

#sample addPayment request
#http://oplink.ciaocrm.com/csnCustomers/addPayment?user_id=1&token=uewyiyutywegfysdvcj&amount=1.2&sn=13110000C83A351FB380

#sample addCustomer request
#http://oplink.ciaocrm.com/csnCustomers/addCustomer?token=uewyiyutywegfysdvcj&phone=76756756&first=x&last=y&country=africa&email=testing@test.com

#sample addOpu request
#http://oplink.ciaocrm.com/csnCustomers/addOpu?token=uewyiyutywegfysdvcj&first=FIRST&last=LAST&sn=SerialNO