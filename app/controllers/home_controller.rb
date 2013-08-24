require 'nokogiri'
require 'savon'
require 'rufus/scheduler'
class HomeController < ApplicationController
	before_filter :authenticate_user!
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
		@customer = Customer.find(params[:id])
		session[:id] = @customer.id
	end

	def after_activate
		@customer = Customer.find(session[:id])
		savon_client = Savon::Client.new("http://test.server.oplink.com:8080/C4miDataExchange/services/C4miForCiaoWebServiceImpl?wsdl")
		#puts savon_client.wsdl.soap_actions
		session[:auth] = "C4miforciao2013"
		session[:phone] = @customer.phone
		session[:opu] = @customer.opu_sn
		#@response = savon_client.request :web, :activate, body: {auth: "C4miforciao2013", phoneNum: "2434325434534", opuSn: "10110000C83A3531D808", enableService: "1"}
		@response = savon_client.request :web, :activate, body: {auth: session[:auth], phoneNum: session[:phone], opuSn: session[:opu], enableService: "1"}
		@message = ActiveSupport::JSON.decode(@response.to_hash[:activate_response][:activate_return].gsub(/:([a-zA-z])/,'\\1'))
		if @message["success"] == "true"
			if params[:method] == "1"
			  @customer.status = "Active"
			  #set the expiration date to be one month from now
			  SCHEDULER.at('#{Time.now + 1.month}') do
			  	@response2= savon_client.request :web, :deactivate, body: {auth: session[:auth], phoneNum: session[:phone], opuSn: session[:opu], enableService: "0"}
				@message2 = ActiveSupport::JSON.decode(@response2.to_hash[:deactivate_response][:deactivate_return].gsub(/:([a-zA-z])/,'\\1'))
				if @message2["success"] == "true"
			  		@customer.status = "Not Active"
			  	else
			  		flash[:alert] = "Could not deactivate customer, #{@message['message']}"
			  	end
			  	#TO DO
			  	#email if the deactivation is not successful
			  end
			  #@customer = Customer.create(:phone => params[:phone], :opu_sn => params[:opu], :activation_date => Time.now, :expiration_date => (Time.now + 1.month.from_now), :status => "active", :first => params[:first], :last => params[:last], :city => params[:city], :country => params[:country], :email => params[:email], :address => params[:address], :balance => 0.0)
			  #Payment.new(:refill_amount => params[:amount], :refill_time => Time.now(), customer_id => Customer.find(@customer.id))   
			  flash[:notice] = "Activation successful!"
			end
			redirect_to "/customers/"
	    elsif @message["success"] == "false"
			flash[:alert] = "Could not activate, #{@message['message']}"
			redirect_to "/home/index"
		end
	end
	#@response = savon_client.request :web, :activate, body: {auth: "C4miforciao2013", phoneNum: "2434325434534", opuSn: "10110000C83A3531D808", enableService: "1"}
end
