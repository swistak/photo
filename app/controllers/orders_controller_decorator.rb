OrdersController.class_eval do
  def approve
    Order.transaction do
      @order.approve!
    end
    flash[:notice] = t('order_updated')
  rescue Spree::GatewayError => ge
    logger.debug("#{ge} \n #{ge.backtrace.join("\n")}")
    flash[:error] = "#{ge.message}"
  ensure
    redirect_to :back
  end
end