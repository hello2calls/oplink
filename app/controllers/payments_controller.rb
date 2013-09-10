require 'rufus/scheduler'
class PaymentsController < ApplicationController
  load_and_authorize_resource

  SCHEDULER = Rufus::Scheduler.start_new
  helper_method :sort_column, :sort_direction
  def index
    @payments = Payment.order(sort_column + ' ' + sort_direction)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @payments }
    end
  end

  def show
    @payment = Payment.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @payment }
    end
  end

  def new
    @payment = Payment.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @payment }
    end
  end

  def edit
  end

  def create
    @payment = Payment.new(params[:payment])
    @opu = Opu.find(@payment.opu_id)
    @payment.opu_sn = @opu.sn
    @customer = Customer.find(@payment.customer_id)
    #code for making sure the activation request went through
    savon_client = Savon::Client.new("http://c4miws.elasticbeanstalk.com/services/C4miForCiaoWebServiceImpl?wsdl")
    session[:auth] = "C4miforciao2013"
    session[:phone] = @customer.phone
    session[:opu] = @payment.opu_sn
    #@response = savon_client.request :web, :activate, body: {auth: "C4miforciao2013", phoneNum: "2434325434534", opuSn: "10110000C83A3531D808", enableService: "1"}
    @response = savon_client.request :web, :activate, body: {auth: session[:auth], phoneNum: session[:phone], opuSn: session[:opu], enableService: "1"}
    @message = ActiveSupport::JSON.decode(@response.to_hash[:activate_response][:activate_return].gsub(/:([a-zA-z])/,'\\1'))
    if @message["success"] == "true"
      if @payment.save
        @opu = Opu.find(@payment.opu_id)
        @customer.status = "Active"
        @opu.status = "Active"
        @opu.activation_date = Time.now
        @opu.expiration_date = Time.now + 1.month
        if @opu.save
          #set the expiration date to be one month from now
          SCHEDULER.at('#{Time.now + 1.month}') do
            @response2= savon_client.request :web, :deactivate, body: {auth: session[:auth], phoneNum: session[:phone], opuSn: session[:opu], enableService: "0"}
            @message2 = ActieSupport::JSON.decode(@response2.to_hash[:deactivate_response][:deactivate_return].gsub(/:([a-zA-z])/,'\\1'))
            if @message2["success"] == "true"
                @customer.status = "Not Active"
            else
              flash[:alert] = "Could not deactivate customer, #{@message['message']}"
            end
            #TO DO
            #email if the deactivation is not successful
          end
          @customer.save
          flash[:notice] = "Activation successful!"
        else
          flash[:alert] = "Coul not activate the opu!"
        end
        flash[:notice] = 'Payment was successfully created.'
      else
        flash[:error] =  '#{@payment.errors}'
      end
    elsif @message["success"] == "false"
      flash[:alert] = "Could not activate, #{@message['message']}"
    end
    respond_to do |format|
      if @payment.save
        format.html { redirect_to @payment, notice: 'Payment was successfully created.' }
        format.json { render json: @payment, status: :created, location: @payment }
      else
        format.html { render action: "new" }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @payment.update_attributes(params[:payment])
        format.html { redirect_to @payment, notice: 'Payment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @payment.destroy

    respond_to do |format|
      format.html { redirect_to payments_url }
      format.json { head :no_content }
    end
  end

  private
  def sort_column
    Payment.column_names.include?(params[:sort]) ? params[:sort] : "date"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
  end
end
