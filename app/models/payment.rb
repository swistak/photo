class Payment < ActiveRecord::Base
  belongs_to :order 
  after_create :check_payments
  after_update :check_payments, :if => lambda{|r| r.order.checkout_complete}
  after_destroy :check_payments
  
  def check_payments                            
    if order.payment_total >= order.prepay_total && order.can_prepay?
      order.prepay!
    elsif order.payment_total >= order.total && order.can_pay?
      order.pay!
    else
      logger.debug "Payment was recived, but did not change order status.\n"+
        "payment_total: #{order.payment_total}, prepay_total: #{order.prepay_total}, total: #{order.total}"+
        "state: #{order.state}"
    end
  end
end