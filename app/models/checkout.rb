class Checkout < ActiveRecord::Base  
  before_save :process_credit_card
  after_save :process_coupon_code
  
  belongs_to :order
  belongs_to :bill_address, :foreign_key => "bill_address_id", :class_name => "Address"
  has_one :shipment, :through => :order, :source => :shipments, :order => "shipments.created_at ASC"                       
  
  accepts_nested_attributes_for :bill_address
  accepts_nested_attributes_for :shipment

  # for memory-only storage of creditcard details
  attr_accessor :creditcard    
  attr_accessor :coupon_code

  validates_presence_of :order_id

  private

  def process_creditcard?
    order and creditcard and not creditcard[:number].blank?
  end

  def process_credit_card
    return unless process_creditcard?

    cc = Creditcard.new(creditcard.merge(:address => self.bill_address, :checkout => self))
    return false unless cc.valid?

    if order.checkout_complete
      to_pay = order.total - order.payment_total
      if to_pay <= 0
        raise "Tried to pay for item that is already paid in full\n"+
          " current state is: #{order.state}\n"+
          " order.total: #{order.total}, payment_total: #{order.payment_total}"
      end
    else
      to_pay = order.prepay_total
    end

    result = if Spree::Config[:auto_capture]
      cc.authorize(to_pay) && order.complete!
    else
      cc.purchase(to_pay)  && order.complete!
    end

    order.payments.last.check_payments

    return(!!result) # always return either true/false
  end

  def process_coupon_code
    return unless @coupon_code and coupon = Coupon.find_by_code(@coupon_code.upcase)
    coupon.create_discount(order)       
    # recalculate order totals
    order.save
  end
end
