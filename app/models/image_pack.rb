class ImagePack < ActiveRecord::Base
  belongs_to :order
  has_many :order_images, :as => :viewable, :order => :position, :dependent => :destroy
end