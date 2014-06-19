CabooseStore::Engine.routes.draw do
  
  # Cart
  
  get    '/cart/mobile'   => 'cart#mobile'
  get    '/cart/items'    => 'cart#list'
  post   '/cart/item/:id' => 'cart#add'
  post   '/cart/item'     => 'cart#add'
  put    '/cart/item/:id' => 'cart#update'
  delete '/cart/item/:id' => 'cart#remove'
  
  # Checkout
  
  get  '/checkout'                        => 'checkout#index'
  put  '/checkout/address'                => 'checkout#update_address'
  get  '/checkout/shipping'               => 'checkout#shipping'
  get  '/checkout/shipping-rates'         => 'checkout#shipping_rates'
  put  '/checkout/shipping-method'        => 'checkout#update_shipping_method'
  get  '/checkout/discount'               => 'checkout#discount'
  post '/checkout/discount'               => 'checkout#add_discount'
  get  '/checkout/authorize-by-gift-card' => 'checkout#authorize_by_gift_card'
  get  '/checkout/billing'                => 'checkout#billing'
  get  '/checkout/relay/:order_id'        => 'checkout#relay'
  get  '/checkout/empty'                  => 'checkout#empty'
  get  '/checkout/error'                  => 'checkout#error'
  get  '/checkout/thanks'                 => 'checkout#thanks'
  
  # Products
  
  get  '/products/:id'    => 'products#index', constraints: {id: /.*/}
  get  '/products'        => 'products#index'

  post '/variants/find-by-options'   => 'variants#find_by_options'
  get  '/variants/:id/display-image' => 'variants#display_image'
  
  get '/admin/variants/group' => 'variants#admin_group'
  
  
  get  '/admin/products/:id/variants/group'  => 'products#admin_group_variants'
  post '/admin/products/:id/variants/add'    => 'products#admin_add_variants'
  post '/admin/products/:id/variants/remove' => 'products#admin_remove_variants'
  
  get '/admin/products/add-upcs' => 'products#admin_add_upcs'
  
  get  '/admin/vendors'                => 'vendors#admin_index'
  get  '/admin/vendors/status-options' => 'vendors#status_options'
  get  '/admin/vendors/new'            => 'vendors#admin_new'
  get  '/admin/vendors/:id/edit'       => 'vendors#admin_edit'
  post '/admin/vendors/create'         => 'vendors#admin_create'
  put  '/admin/vendors/:id/update'     => 'vendors#admin_update'
  
  # Orders
  
  get  '/admin/orders/:id/void'                => 'orders#admin_void'
  get  '/admin/orders/:id/refund'              => 'orders#admin_refund'
  post '/admin/orders/:id/resend-confirmation' => 'orders#admin_resend_confirmation'
  
  ###########################
  
  post    "/reviews/add"                                => "reviews#add"  

  get     "/admin/products"                             => "products#admin_index"
  get     '/admin/products/sort'                        => 'products#admin_sort'
  put     '/admin/products/update-sort-order'           => 'products#admin_update_sort_order'
  put     "/admin/products/update-vendor-status/:id"    => "products#admin_update_vendor_status"
  get     "/admin/products/new"                         => "products#admin_new"
  get     "/admin/products/status-options"              => "products#admin_status_options"  
  get     "/admin/products/:id/general"                 => "products#admin_edit_general"    
  get     "/admin/products/:id/description"             => "products#admin_edit_description"
  get     "/admin/products/:id/categories"              => "products#admin_edit_categories"
  post    "/admin/products/:id/categories"              => "products#admin_add_to_category"
  delete  "/admin/products/:id/categories/:category_id" => "products#admin_remove_from_category"
  get     "/admin/products/:id/variants"                => "products#admin_edit_variants"
  get     "/admin/products/:id/variants/json"           => "products#admin_variants_json"
  get     "/admin/products/:id/variant-cols"            => "products#admin_edit_variant_columns"
  put     "/admin/products/:id/variant-cols"            => "products#admin_update_variant_columns"    
  get     "/admin/products/:id/images"                  => "products#admin_edit_images"
  post    "/admin/products/:id/images"                  => "products#admin_add_image"
  get     "/admin/products/:id/collections"             => "products#admin_edit_collections"
  get     "/admin/products/:id/seo"                     => "products#admin_edit_seo"
  get     "/admin/products/:id/options"                 => "products#admin_edit_options"
  get     "/admin/products/:id/delete"                  => "products#admin_delete_form"
  put     "/admin/products/:id"                         => "products#admin_update"
  post    "/admin/products"                             => "products#admin_add"
  delete  "/admin/products/:id"                         => "products#admin_delete"
  put     "/admin/products/:id/update-vendor"           => "products#admin_update_vendor"
  
  get     "/admin/products/:product_id/variants/:variant_id/edit"   => "variants#admin_edit"
  get     "/admin/variants/status-options"            => "variants#admin_status_options"
  get     "/admin/variants/:variant_id/edit"          => "variants#admin_edit"
  put     "/admin/variants/:id/attach-to-image"       => "variants#admin_attach_to_image"
  put     "/admin/variants/:id/unattach-from-image"   => "variants#admin_unattach_from_image"
  put     "/admin/variants/:id"                       => "variants#admin_update"  
  get     "/admin/products/:id/variants/new"          => "variants#admin_new"  
  post    "/admin/products/:id/variants"              => "variants#admin_add"
  delete  "/admin/variants/:id"                       => "variants#admin_delete"
  
  get     "/admin/categories"                         => "categories#admin_index"
  get     "/admin/categories/new"                     => "categories#admin_new"
  get     "/admin/categories/options"                 => "categories#admin_options"  
  get     "/admin/categories/:id/edit"                => "categories#admin_edit"  
  put     "/admin/categories/:id"                     => "categories#admin_update"  
  post    "/admin/categories/:id"                     => "categories#admin_update"  
  post    "/admin/categories"                         => "categories#admin_add"
  delete  "/admin/categories/:id"                     => "categories#admin_delete"
  
  get     "/admin/product-images/:id/variant-ids"     => "product_images#admin_variant_ids"
  get     "/admin/product-images/:id/variants"        => "product_images#admin_variants"
  delete  "/admin/product-images/:id"                 => "product_images#admin_delete"
  get     "/variant-images/:id"                       => "product_images#variant_images"
  
  get     "/admin/orders"                             => "orders#admin_index"
  get     "/admin/orders/test-info"                   => "orders#admin_mail_test_info"
  get     "/admin/orders/test-gmail"                  => "orders#admin_mail_test_gmail"
  get     "/admin/orders/line-item-status-options"    => "orders#admin_line_item_status_options"
  get     "/admin/orders/status-options"              => "orders#admin_status_options"
  get     "/admin/orders/new"                         => "orders#admin_new"
  get     "/admin/orders/:id/capture"                 => "orders#capture_funds"  
  get     "/admin/orders/:id/json"                    => "orders#admin_json"
  get     "/admin/orders/:id/print"                   => "orders#admin_print"
  get     "/admin/orders/:id/send-to-quickbooks"      => "orders#admin_send_to_quickbooks"
  get     "/admin/orders/:id"                         => "orders#admin_edit"        
  put     "/admin/orders/:id"                         => "orders#admin_update"
  put     "/admin/orders/:order_id/line-items/:id"    => "orders#admin_update_line_item"
  delete  "/admin/orders/:id"                         => "orders#admin_delete"
	
end
