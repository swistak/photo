class OrderMailer < ActionMailer::Base
  helper "spree/base"
  
  def confirm(order, resend = false)
    @subject    = (resend ? "[RESEND] " : "") 
    @subject    += Spree::Config[:site_name] + ' ' + 'Order Confirmation #' + order.number
    @body       = {"order" => order}
    @recipients = order.email
    @from       = Spree::Config[:order_from]
    @bcc        = order_bcc
    @sent_on    = Time.now
  end
  
  def cancel(order)
    @subject    = '[CANCEL]' + Spree::Config[:site_name] + ' Order Confirmation #' + order.number
    @body       = {"order" => order}
    @recipients = order.email
    @from       = Spree::Config[:order_from]
    @bcc        = order_bcc
    @sent_on    = Time.now
  end

  def preview_image_added(order)
    @subject    = '[UPDATE]' + Spree::Config[:site_name] + ' New preview image in order #' + order.number
    @body       = {"order" => order}
    @recipients = order.email
    @from       = Spree::Config[:order_from]
    @bcc        = order_bcc
    @sent_on    = Time.now
  end

  def shipped(order)
    @subject    = '[SHIPPED]' + Spree::Config[:site_name] + ' Order shipped #' + order.number
    @body       = {"order" => order}
    @recipients = order.email
    @from       = Spree::Config[:order_from]
    @bcc        = order_bcc
    @sent_on    = Time.now
  end

  def upload_reminder
    @subject    = '[REMINDER]' + Spree::Config[:site_name] + ' Order #' + order.number
    @body       = {"order" => order}
    @recipients = order.email
    @from       = Spree::Config[:order_from]
    @bcc        = order_bcc
    @sent_on    = Time.now
  end
  
  private
  def order_bcc
    [Spree::Config[:order_bcc], Spree::Config[:mail_bcc]].delete_if { |email| email.blank? }.uniq
  end
end
