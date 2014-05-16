class Publisher::TermsController < Publisher::ApplicationController
  
  skip_filter :check_terms
  
  def edit
    @term = Term.current_enabled_term
    if current_publisher.partner && current_publisher.partner.partner_tracking_code
      cookies[:ptc] = current_publisher.partner.partner_tracking_code
    else
      cookies[:ptc] = nil
    end
    cookies[:ptc_showed_terms] = cookies[:ptc].to_s
  end

  def update
    @term = Term.current_enabled_term
    current_publisher.attributes = params[:publisher]
    
    if params[:confirm].nil?
      flash.now[:notice] = t('publisher.terms.not_accepted')
      render :edit
      return
    else
      current_publisher.accepted_term = @term
      fb_pb = current_publisher.publisher_facebooks[0]
      if fb_pb
        fb_pb.update_attribute(:app_version, 'paypersocial 1.0')
        fb_pb.update_attribute(:app_version_date, Time.now.utc)
      end 
    end
    
    unless current_publisher.accepted_all_terms?
      flash.now[:notice] = t("publisher.info_mandatory_data")
      render :edit
      return
    end
    
    if !current_publisher.coupon && !params[:coupon].blank?
      unless (user_coupon = params[:coupon][:code]).blank?
        coupon = Coupon.where(:code => user_coupon, :partner_id => current_publisher.partner.id).first
        if coupon && coupon.active_coupon?
          current_publisher.coupon = coupon
          cookies[:coupon_added] = 'yes'
        else
          flash.now[:notice] = t("publisher.coupon.#{invalid_coupon_msg(coupon)}", :coupon => user_coupon)
          render :edit
          return
        end
      end
    end
    
    current_publisher.engage_date = Time.now.utc unless current_publisher.engage_date
    if current_publisher.save
      #TODO: see if it does make sense to add it to transaction with save method
      BillingService.new.register_partner_coupon(current_publisher) if coupon
      cookies[:ptc_accepted_terms] = cookies[:ptc].to_s
      redirect_to get_dashboard
    else
      !current_publisher.coupon = nil if coupon # otherwise entered coupon code will not be displayed
      flash.now[:notice] = current_publisher.errors.full_messages[0]
      render :edit
      return
    end
  end

  protected
  
  def get_dashboard
    raise "should be implemented in child controller"
  end

  private

  def invalid_coupon_msg(coupon)
    case Coupon.status(coupon)
    when Coupon::NONACTIVE
      "not_active"
    when Coupon::EXPIRED
      "expired"
    when Coupon::UNAVAILABLE
      "unavailable"
    else
      "not_valid"
    end
  end

end
