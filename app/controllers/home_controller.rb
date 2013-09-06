require 'nokogiri'
require 'savon'
require 'rufus/scheduler'
require 'mail'
class HomeController < ApplicationController
	before_filter :authenticate_user!
	SEARCH_OPTIONS = ['Name', 'Email', 'Phone', 'ID']
	SCHEDULER = Rufus::Scheduler.start_new
	def index
		doc = Nokogiri::XML('<?xml version="1.0"?>
		  <library>
		    <NAME><![CDATA[Favorite Books]]></NAME>
		    <book ISBN="11342343">
		      <title>To Kill A Mockingbird</title>
		      <description><![CDATA[Description#1]]></description>
		      <author>Harper Lee</author>
		    </book>
		    <book ISBN="989894781234">
		      <title>Catcher in the Rye</title>
		      <description><![CDATA[This is an extremely intense description.]]></description>
		      <author>J. D. Salinger</author>
		    </book>
		    <book ISBN="123456789">
		      <title>Murphy\'s Gambit</title>
		      <description><![CDATA[Daughter finds her dad!]]></description>
		      <author>Syne Mitchell</author>
		    </book>
		  </library>')

		doc.css('book').each do |node|
		  children = node.children

		  book = {
		    "isbn" => node['ISBN'], 
		    "title" => children.css('title').inner_text, 
		    "description" => children.css('description').inner_text, 
		    "author" => children.css('author').inner_text
		  }
		end
	end

	def activate_disable
		@customer = Customer.find(params[:customer_id])
		session[:customer_id] = @customer.id
		@id = params[:id]
		session[:id] = @id
	end

	def after_activate
		#email notification
		from = "its.ciaotelecom@gmail.com"
		subject = "Oplink action"
		options = { :address              => "smtp.gmail.com",
		           :port                 => 587,
		           :domain               => 'ciaotelecom.net',
		           :user_name            => 'its.ciaotelecom@gmail.com',
		           :password             => 'ciao450750',
		           :authentication       => 'plain',
		           :enable_starttls_auto => true  }
		Mail.defaults do
			delivery_method :smtp, options
		end

		@customer = Customer.find(session[:customer_id])
		savon_client = Savon::Client.new("http://c4miws.elasticbeanstalk.com/services/C4miForCiaoWebServiceImpl?wsdl")
		#puts savon_client.wsdl.soap_actions
		session[:auth] = "C4miforciao2013"
		session[:phone] = @customer.phone
		session[:opu] = params[:opu]
		session[:action] = params[:method]
		@opu = Opu.find_by_sn(session[:opu])
		#@response = savon_client.request :web, :get_owner_opu_info_by_opu_sn, body: {auth: "C4miforciao2013", phoneNum: "2434325434534", opuSn: "10110000C83A3531D808"}
		@response = savon_client.request :web, :activate, body: {auth: session[:auth], phoneNum: session[:phone], opuSn: session[:opu], enableService: session[:action]}
		@message = ActiveSupport::JSON.decode(@response.to_hash[:activate_response][:activate_return].gsub(/:([a-zA-z])/,'\\1'))
		if @message["success"] == "true"
			if params[:method] == "1"
			  #set the expiration date to be one month from now
			  SCHEDULER.at('#{Time.now + 1.month}') do
			  	@response2= savon_client.request :web, :activate, body: {auth: session[:auth], phoneNum: session[:phone], opuSn: session[:opu], enableService: "0"}
				@message2 = ActiveSupport::JSON.decode(@response2.to_hash[:activate_response][:activate_return].gsub(/:([a-zA-z])/,'\\1'))
				if @message2["success"] == "true"
			  		@opu.status = "Not Active"
			  		@opu.save
			  		#notify deactivation success via email
				  	begin 
						Mail.deliver do
					   		to 'aldizhupani@gmail.com'
					   		from "#{from}"
					   		subject "#{subject}"
					   		#body "hi"
					   		body "Deactivation date set as #{Time.now + 1.month}"
						end

					rescue Exception => e
				 		flash[:alert] = "You message was not sent! Please try again!"
		    		end
			  	else
			  		flash[:alert] = "Could not deactivate customer, #{@message['message']}"
			  	end

			  end
			  begin 
				Mail.deliver do
				   	to 'aldizhupani@gmail.com'
			   		from "#{from}"
			   		subject "#{subject}"
			   		body "Activation successful"
				end

			  rescue Exception => e
			 	flash[:error] = "You message was not sent! Please try again!"
	    	  end
	    	  @opu.status = "Active"
			  @opu.save
			  #@customer = Customer.create(:phone => params[:phone], :opu_sn => params[:opu], :activation_date => Time.now, :expiration_date => (Time.now + 1.month.from_now), :status => "active", :first => params[:first], :last => params[:last], :city => params[:city], :country => params[:country], :email => params[:email], :address => params[:address], :balance => 0.0)
			  #Payment.new(:refill_amount => params[:amount], :refill_time => Time.now(), customer_id => Customer.find(@customer.id))   
			  flash[:notice] = "Activation successful!"
			elsif params[:method] == "0"
			  @response3= savon_client.request :web, :activate, body: {auth: session[:auth], phoneNum: session[:phone], opuSn: session[:opu], enableService: "0"}
			  @message3 = ActiveSupport::JSON.decode(@response3.to_hash[:activate_response][:activate_return].gsub(/:([a-zA-z])/,'\\1'))
			  if @message3["success"] == "true"
			    @opu.status = "Not Active"
			  	@opu.save
			    flash[:alert] = "Customer no longer active!"
			    redirect_to "/opus/"
			  else
			    flash[:notice] = "Deactivation successful"
			    redirect_to "/opus/"
			  end
			end
			setStatus(@customer)
	    elsif @message["success"] == "false"
			flash[:alert] = "Could not complete the request, #{@message['message']}"
			redirect_to "/home/index"
		end
	end

	def getOpuInfo
	end

    def displayOpuInfo
    	savon_client = Savon::Client.new("http://c4miws.elasticbeanstalk.com/services/C4miForCiaoWebServiceImpl?wsdl")
    	#savon_client = Savon::Client.new("http://test.server.oplink.com:8080/C4miDataExchange/services/C4miForCiaoWebServiceImpl?wsdl")
		@response = savon_client.request :web, :get_owner_opu_info_by_opu_sn, body: {auth: "C4miforciao2013", opuSn: params[:input]}
		@response1 = savon_client.request :web, :get_owner_opu_info_by_phone_num, body: {auth: "C4miforciao2013", phone: params[:input]}
		if @response[:get_owner_opu_info_by_opu_sn_response][:get_owner_opu_info_by_opu_sn_return]
			@first = @response[:get_owner_opu_info_by_opu_sn_response][:get_owner_opu_info_by_opu_sn_return][:first_name]
			@last = @response[:get_owner_opu_info_by_opu_sn_response][:get_owner_opu_info_by_opu_sn_return][:last_name]
			@owner =  @response[:get_owner_opu_info_by_opu_sn_response][:get_owner_opu_info_by_opu_sn_return][:owner_email]
			if @response[:get_owner_opu_info_by_opu_sn_response][:get_owner_opu_info_by_opu_sn_return][:servicestatus] == "1"
				@status = "active"
			else
				@status = "Not active"
			end
		elsif @response1[:get_owner_opu_info_by_phone_num_response][:get_owner_opu_info_by_phone_num_return]
			@first = @response1[:get_owner_opu_info_by_phone_num_response][:get_owner_opu_info_by_phone_num_return][:first_name]
			@last = @response1[:get_owner_opu_info_by_phone_num_response][:get_owner_opu_info_by_phone_num_return][:last_name]
			@owner =  @response1[:get_owner_opu_info_by_phone_num_response][:get_owner_opu_info_by_phone_num_return][:owner_email]
			if @response1[:get_owner_opu_info_by_phone_num_response][:get_owner_opu_info_by_phone_num_return][:servicestatus] == "1"
				@status = "active"
			else
				@status = "Not active"
			end
		else
			flash[:alert] = "Sorry, but we couldn't locate this opu!"
			redirect_to "/home/index"
		end
    end
    def showCustomer
    	customer = findCustomer(params[:search][:value], params[:input])
    	if customer
    		redirect_to customer_path(customer)
    	else
    		flash[:alert] = "Sorry, couldn't find this customer!"
    		redirect_to "/home/index"
    	end
    end

    private
    def findCustomer(criteria, value)
    	@customer = nil
    	if criteria == "1"
    		parts = value.split(" ")
    	    @customer = Customer.where(first: parts[0], last: parts[1]).first
    	elsif criteria == "2"
    		@customer = Customer.find_by_email(value)
    	elsif criteria == "3"
    		@customer = Customer.find_by_phone(value)
    	elsif criteria == "4"
    		@customer = Customer.find(value.to_i)
    	end
    	#params = {:customer_id => @customer.id, :opu_sn => "13110000C83A351FB380"}
		#puts Payment.find(:all, :conditions => ["customer_id LIKE :customer_id AND opu_sn = :opu_sn", params])
		if @customer
			@opus_for_this_customer = Opu.where(:customer_id => @customer.id)
	    	@temp = Payment.where(:customer_id => @customer.id)
	    	return @customer
	    end
    end

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
end

#for production
#savon_client = Savon::Client.new("https://c4miws.elasticbeanstalk.com/services/C4miForCiaoWebServiceImpl?wsdl")
#@response = savon_client.request :web, :get_owner_opu_info_by_opu_sn, body: {auth: "C4miforciao2013", opuSn: "13110000C83A351FB380"}
#@response = savon_client.request :web, :activate, body: {auth: "C4miforciao2013", phoneNum: "2434325434534", opuSn: "13110000C83A351FB380", enableService: "0"}

