require 'nokogiri'
require 'savon'
class HomeController < ApplicationController

	before_filter :authenticate_user!
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
	end

	def after_activate
		client = Savon::Client.new("http://test.server.oplink.com:8080/C4miDataExchange/services/C4miForCiaoWebServiceImpl?wsdl")
		#puts client.wsdl.soap_actions
		session[:auth] = params[:auth]
		session[:phone] = params[:phone]
		session[:opu] = params[:opu]
		@response = client.request :web, :activate, body: {auth: params[:auth], phoneNum: params[:phone], opuSn: params[:opu], enableService: params[:method]}
		@message = ActiveSupport::JSON.decode(@response.to_hash[:activate_response][:activate_return].gsub(/:([a-zA-z])/,'\\1'))
		if @message["success"] == "true"
			flash[:notice] = "Activation successful!"
			redirect_to "/home/index"
	    elsif @message["success"] == "false"
			flash[:error] = "#{@message['message']}"
			redirect_to "/home/index"
		end
	end

	def customers
		
	end
end
