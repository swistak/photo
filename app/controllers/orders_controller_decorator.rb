OrdersController.class_eval do
  def approve
    if request.post?

      flash[:notice] = t('order_updated')
    else
      @checkout = Checkout.new(:order => @order)
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