class CustomersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :except => [:payment_history]
  
  def index
    @customers = Customer.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @customers }
    end
  end

  def show
    @opu_names = []
    @opus = Opu.where(:customer_id => @customer.id)
    @opus.each do |opu|
      @opu_names.push(opu.sn)
    end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @customer }
    end
  end

  def new
    @customer = Customer.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @customer }
    end
  end

  def edit
  end

  def payment_history
    @customer = Customer.find(params[:id])
    @payments = Payment.where(:customer_id => @customer.id)
  end

  def create
    @customer = Customer.new(params[:customer])
    @customer.status = "Not active"
    @customer.balance = 0.0
    respond_to do |format|
      if @customer.save
        format.html { redirect_to @customer, notice: 'Customer was successfully created.' }
        format.json { render json: @customer, status: :created, location: @customer }
      else
        format.html { render action: "new" }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @customer.update_attributes(params[:customer])
        format.html { redirect_to @customer, notice: 'Customer was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @customer = Customer.find(params[:id])
    @customer.destroy

    respond_to do |format|
      format.html { redirect_to customers_url }
      format.json { head :no_content }
    end
  end
end
