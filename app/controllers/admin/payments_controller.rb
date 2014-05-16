class Admin::PaymentsController < Admin::ApplicationController
  def index
    @payments = Payment.all
  end

  def new
    @payment = Payment.new
  end

  def edit
    @payment = Payment.find(params[:id])
  end

  def create
    @payment = Payment.new(params[:payment])
    if @payment.save
      redirect_to(edit_admin_payment_path(@payment), :notice => 'payment was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @payment = Payment.find(params[:id])
    if @payment.update_attributes(params[:payment])
      redirect_to(edit_admin_payment_path(@payment), :notice => 'payment was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @payment = Payment.find(params[:id])
    @payment.destroy
    redirect_to(admin_payments_url)
  end
end
