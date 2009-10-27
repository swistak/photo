map.resources :orders do |order|
  order.resources :images, :path_prefix => '/orders/:order_id/:image_pack_type'
end

map.resources :orders, :member => {:approve => :post}