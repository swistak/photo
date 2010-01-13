class OrderMailer < ActionMailer::Base
  helper "spree/base"

  # TODO: Select events you want notify with email. and prepare proper erb files
  #NOTIFY_USER_ON = %w{new prepaid preview_available paid shipped upload_remonder}
  #NOTIFY_ADMINS_ON = %w{ready_for_processing preview_reejected ready_for_fulfillment}
  NOTIFY_USER_ON = %w{new}
  NOTIFY_ADMINS_ON = []

  # All states during which user should be notified by email
  NOTIFY_USER_ON.each do |state|
    define_method(state) do |order, user|
      @subject    = "#{Spree::Config[:site_name]}: [#{I18n.t(state)}] ##{order.number}"
      @body       = {"order" => order, 'user' => user}
      @recipients = order_email(order)
      @from       = Spree::Config[:order_from]
      @bcc        = order_bcc
      @sent_on    = Time.now
    end
  end

  # All states where administrators should be notified about change in order
  NOTIFY_ADMINS_ON.each do |state|
    define_method(state) do |order|
      @subject    = "#{Spree::Config[:site_name]}: [#{I18n.t(state)}] ##{order.number}"
      @body       = {"order" => order}
      @recipients = User.all.select{|u| u.has_role?("admin")}.map(&:email)
      @from       = Spree::Config[:order_from]
      @bcc        = order_bcc
      @sent_on    = Time.now
    end
  end
  
  private
  def order_email(order)
    [order, order.user].delete_if{ |r| !r || r.email.blank? }.uniq
  end

  def order_bcc
    [Spree::Config[:order_bcc], Spree::Config[:mail_bcc]].delete_if { |email| email.blank? }.uniq
  end
end
