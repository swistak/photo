class OrderMailerObserver < ActiveRecord::Observer
  observe :order

  def after_ship(order, from_state, to_state)
    OrderMialer.deliver_shipped(order)
  end

  def after_foo(order, from_state, to_state)
    
  end
end
