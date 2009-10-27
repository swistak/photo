class ImagesController < Spree::BaseController
  resource_controller
  before_filter :load_data
  belongs_to :order

  helper Admin::BaseHelper

  new_action.response do |wants|
    wants.html {render :action => :new, :layout => false}
  end

  create.response do |wants|
    wants.html {redirect_to order_images_url(@order, @image_pack_type)}
  end

  update.response do |wants|
    wants.html {redirect_to order_images_url(@order, @image_pack_type)}
  end

  create.before do
    object.viewable_type = 'ImagePack'
    object.viewable_id = @image_pack.id
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
    @image_pack_type = params[:image_pack_type]
    @image_pack_type = 'user_images' unless ['previews', 'user_images'].include?(@image_pack_type)
    args = {:order_id => @order.id, :pack_type => @image_pack_type}
    @image_pack = ImagePack.find(:first, :conditions => args) || ImagePack.create!(args)
  end

  def build_object
    @image ||= @image_pack.order_images.new(params[:image])
  end

  def object
    @object ||= OrderImage.find(:first, :conditions => {
        :viewable_type => "ImagePack",
        :viewable_id => @image_pack.id,
        :id => params[:id]
      }) || OrderImage.new(params[:image])
  end

  def collection
    @images = @image_pack.order_images
  end
end
