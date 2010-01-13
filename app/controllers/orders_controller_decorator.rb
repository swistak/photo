OrdersController.class_eval do
  def approve
    @checkout = @order.checkout
    @order.approve_preview

    if request.post? && params[:creditcard]
      cc = Creditcard.new(params[:creditcard].merge(:address => @checkout.bill_address, :checkout => @checkout))
      if cc.valid?
        to_pay = @order.total - @order.payment_total
        result = if Spree::Config[:auto_capture]
          cc.authorize(to_pay)
        else
          cc.purchase(to_pay)
        end
        @order.payments.last.check_payments
        if result
          flash[:notice] = t('order_processed_successfully')
          redirect_to :action => 'show'
        else
          flash[:error] = t("unable_to_authorize_credit_card")
        end
      else
        flash[:error] = t('creditcard_invalid')
      end
    else
      ccp = @order.creditcard_payments.last
      if ccp && ccp.creditcard
        @creditcard = ccp.creditcard
      else
        @creditcard = Creditcard.new
      end
    end
    
  rescue Spree::GatewayError => ge
    logger.debug("#{ge} \n #{ge.backtrace.join("\n")}")
    flash[:error] = "#{ge.message}"
  end

  def reeject
    Order.transaction do
      @order.reeject_preview!
    end
    flash[:notice] = t('order_updated')
  rescue Spree::GatewayError => ge
    logger.debug("#{ge} \n #{ge.backtrace.join("\n")}")
    flash[:error] = "#{ge.message}"
  ensure
    redirect_to :back
  end
end