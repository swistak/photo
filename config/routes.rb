map.resources :orders do |order|
  order.resources :images, :path_prefix => '/orders/:order_id'
end

map.resources :orders, :member => {:approve => :any, :reeject => :post}