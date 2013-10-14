class OpusController < ApplicationController
  load_and_authorize_resource

  def index
    @opus = Opu.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @opus }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @opu }
    end
  end

  def new
    @opu = Opu.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @opu }
    end
  end

  def edit
  end

  def create
    @opu = Opu.new(params[:opu])
    respond_to do |format|
      if @opu.save
        format.html { redirect_to @opu, notice: 'Opu was successfully created.' }
        format.json { render json: @opu, status: :created, location: @opu }
      else
        format.html { render action: "new" }
        format.json { render json: @opu.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @opu = Opu.find(params[:id])

    respond_to do |format|
      if @opu.update_attributes(params[:opu])
        format.html { redirect_to @opu, notice: 'Opu was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @opu.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @opu = Opu.find(params[:id])
    @opu.destroy
    customer = Customer.find(@opu.customer_id)
    setStatus(customer)
    
    respond_to do |format|
      format.html { redirect_to opus_url }
      format.json { head :no_content }
    end
  end
end
