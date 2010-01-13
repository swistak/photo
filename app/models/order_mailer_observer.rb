class OrderMailerObserver < ActiveRecord::Observer
  observe :order

  # Generic transition callback *after* the transition is performed
  def after_transition(order, attribute_name, event_name, from_state, to_state)
    current_user_session = UserSession.activated? ? UserSession.find : nil
    user = current_user_session ? current_user_session.user : order.user

    if OrderMailer.respond_to?("deliver_#{to_state}")
      OrderMailer.send("deliver_#{to_state}", order, user)
    end
  end
end
