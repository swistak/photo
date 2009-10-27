Order.class_eval do
  has_one :user_images,  :class_name => "ImagePack", :conditions => {:pack_type => 'user_images'}
  has_one :previews,     :class_name => "ImagePack", :conditions => {:pack_type => 'preview'}

  module ClassMethods
    def send_reminders(lack_of_activity = 7.days)
      all(:conditions => [
          "orders.updated_at < ? AND state = 'new'", Time.now - lack_of_activity
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
      transition :to => 'new', :from => 'in_progress'
    end
    event :image_added do
      transition :from => 'new', :to => 'in_realization'
    end
    event :approve do
      transition :from => 'in_realization', :to => 'approved'
    end
    event :cancel do
      transition :to => 'canceled', :if => :allow_cancel?
    end
    event :return do
      transition :to => 'returned', :from => 'shipped'
    end
    event :resume do
      transition :to => 'resumed', :from => 'canceled', :if => :allow_resume?
    end
    event :pay do
      transition :to => 'paid', :from => ['new', 'approved']
    end
    event :ship do
      transition :to => 'shipped', :from => ['paid', 'approved']
    end
  end
end
