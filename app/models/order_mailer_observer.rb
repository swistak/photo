class OrderMailerObserver < ActiveRecord::Observer
  observe :order

  def after_ship(order, from_state, to_state)
    OrderMialer.deliver_shipped(order)
  end
end
