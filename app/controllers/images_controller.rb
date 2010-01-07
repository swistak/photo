class ImagesController < Spree::BaseController
  resource_controller
  before_filter :load_data
  belongs_to :order

  helper Admin::BaseHelper

  new_action.response do |wants|
    wants.html {render :action => :new, :layout => false}
  end

  create.response do |wants|
    wants.html {redirect_to order_images_url(@order)}
  end

  update.response do |wants|
    wants.html {redirect_to order_images_url(@order)}
  end

  destroy.before do
    @viewable = object.viewable
  end

  destroy.response do |wants|
    wants.html do
      render :text => ""
    end
  end

  private

  def load_data
    @order = Order.find_by_number(params[:order_id])
    @line_items = @order.line_items(:joins => :product).select{|li| li.product.photo_required?}
  end
end
