Order.class_eval do
  module ClassMethods
    def send_reminders(lack_of_activity = 7.days)
      all(:conditions => [
          "orders.updated_at < ? AND has_user_images = ?",
          Time.now - lack_of_activity, false
        ]).each do |order|
        OrderMailer.deliver_upload_reminder(order)  
      end
    end
  end
  extend ClassMethods

  # clears callbacks on state machine to prevent double checkout, double mails etc.
  after_transition_state_callback_chain.clear
  
  # order state machine (see http://github.com/pluginaweek/state_machine/tree/master for details)
  state_machine :initial => 'in_progress' do
    after_transition :to => 'in_progress', :do => lambda {|order| order.update_attribute(:checkout_complete, false)}
    after_transition :to => 'new', :do => :complete_order
    after_transition :to => 'canceled', :do => :cancel_order
    after_transition :to => 'returned', :do => :restock_inventory
    after_transition :to => 'resumed', :do => :restore_state

    event :complete do
      transition :from => 'in_progress', :to => 'new'
    end

    event :prepay do
      transition :from => ['new'], :to => 'prepaid'
    end

    event :add_preview do
      transition :from => ['prepaid', 'preview_reejected'], :to => 'preview_available'
    end
    event :approve_preview do
      transition :from => ['preview_available'], :to => 'approved'
    end
    event :reeject_preview do
      transition :from => ['preview_available'], :to => 'preview_reejected'
    end

    # FInal payment and shipping
    event :pay do
      transition :from => ['new', 'prepaid', 'approved'], :to => 'paid'
    end
    event :ship do
      transition :from => ['paid', 'approved'], :to => 'shipped'
    end

    # Cancelation, return and resume handling
    event :cancel do
      transition :to => 'canceled', :if => :allow_cancel?
    end
    event :return do
      transition :to => 'returned', :from => 'shipped'
    end
    event :resume do
      transition :to => 'resumed', :from => 'canceled', :if => :allow_resume?
    end
  end

  def prepay_total
    self.line_items.all(:joins => {:variant => :product}).map{|li|
      li.variant.product.master.price
    }.sum
  end

  def has_images_from_user
    @line_items = line_items(:joins => [:product, :order_images]).select{|li| li.product.photo_required?}
    @line_items.all?{|li| li.order_images.any?{|oi| oi.author_id == self.user_id}}
  end

  def check_images
    @line_items = line_items(:joins => [:product, :order_images]).select{|li| li.product.photo_required?}
    has_images_from_artist = @line_items.all?{|li| li.order_images.any?{|oi| oi.author_id != self.user_id}}

    update_attribute(:has_user_images, true) if has_images_from_user
    add_preview! if has_images_from_artist && can_add_preview?
  end

  def images
    OrderImage.scoped(:conditions => [
       "line_items.order_id = ? AND
        line_items.variant_id = variants.id AND
        variants.product_id = products.id AND
        products.photo_required = ?",
        self.id, true
      ], :select => 'assets.*', :from => 'assets, line_items, variants, products')
  end

  def can_add_images?
    ['prepaid', 'new', 'preview_reejected', 'preview_available'].include? state
  end

  def needs_images?
    line_items(:joins => :product).any?{|li| li.product.photo_required?}
  end
end
