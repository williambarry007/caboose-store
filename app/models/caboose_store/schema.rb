
class CabooseStore::Schema < Caboose::Utilities::Schema
  
  def self.schema
    {  
      CabooseStore::Address => [
        [ :id            , :integer ],
        [ :name          , :string  ],
        [ :first_name    , :string  ],
        [ :last_name     , :string  ],
        [ :street        , :string  ],
        [ :address1      , :string  ],
        [ :address2      , :string  ],
        [ :company       , :string  ],
        [ :city          , :string  ],
        [ :state         , :string  ],
        [ :province      , :string  ],
        [ :province_code , :string  ],
        [ :zip           , :string  ],
        [ :country       , :string  ],
        [ :country_code  , :string  ],
        [ :phone         , :string  ]
      ],
      CabooseStore::Category => [        
        [ :parent_id	           , :integer   ],
        [ :name	                 , :string    ],
        [ :url	                 , :string    ],
        [ :slug	                 , :string    ],
        [ :image_file_name	     , :string    ],
        [ :image_content_type	   , :string    ],
        [ :image_file_size	     , :integer   ],
        [ :image_updated_at	     , :datetime  ],
        [ :square_offset_x	     , :integer   ],
        [ :square_offset_y	     , :integer   ],
        [ :square_scale_factor	 , :numeric   ],
        [ :sort	                 , :integer   ]
      ],
      CabooseStore::CategoryMembership => [        
        [ :category_id	         , :integer ],
        [ :product_id	           , :integer ]      
      ],
      CabooseStore::Discount => [
        [ :id	                   , :integer  ],
        [ :name	                 , :string   ],
        [ :code	                 , :string   ],
        [ :amount_flat	         , :numeric  ],
        [ :amount_percentage	   , :numeric  ],
        [ :no_shipping	         , :boolean  ],
        [ :no_tax	               , :boolean  ]
      ],
      CabooseStore::OrderDiscount => [
        [ :order_id	             , :integer ],
        [ :discount_id	         , :integer ]
      ],
      CabooseStore::OrderLineItem => [
        [ :order_id	             , :integer  ],
        [ :variant_id	           , :integer  ],
        [ :quantity	             , :integer  ],
        [ :status	               , :string   ],
        [ :tracking_number	     , :string   ],
        [ :quantity_shipped	     , :integer  ],
        [ :unit_price	           , :numeric  ],
        [ :variant_sku	         , :string   ]
      ],
      CabooseStore::Order => [
        [ :email	               , :string   ],
        [ :order_number	         , :string   ],
        [ :subtotal	             , :numeric  ],
        [ :tax	                 , :numeric  ],
        [ :shipping	             , :numeric  ],
        [ :discount	             , :numeric  ],
        [ :total	               , :numeric  ],
        [ :customer_id	         , :integer  ],
        [ :payment_id	           , :integer  ],
        [ :gateway_id	           , :integer  ],
        [ :financial_status	     , :string   ],
        [ :shipping_address_id	 , :integer  ],
        [ :billing_address_id	   , :integer  ],
        [ :notes	               , :text     ],
        [ :status	               , :string   ],
        [ :date_created	         , :datetime ],
        [ :date_authorized	     , :datetime ],
        [ :date_captured	       , :datetime ],
        [ :date_cancelled	       , :datetime ],
        [ :referring_site	       , :text     ],
        [ :landing_page	         , :string   ],
        [ :landing_page_ref	     , :string   ],
        [ :shipping_method_code	 , :string   ],
        [ :shipping_method	     , :string   ],
        [ :handling	             , :numeric  ],
        [ :transaction_id	       , :string   ],
        [ :auth_code	           , :string   ],
        [ :alternate_id	         , :integer  ],
        [ :auth_amount	         , :numeric  ],
        [ :date_shipped	         , :datetime ],
        [ :transaction_id	       , :string   ],
        [ :transaction_service   , :string   ]
      ],
      CabooseStore::ProductImage => [
        [ :product_id	           , :integer  ],
        [ :title	               , :string   ],
        [ :image_file_name	     , :string   ],
        [ :image_content_type	   , :string   ],
        [ :image_file_size	     , :integer  ],
        [ :image_updated_at	     , :datetime ],
        [ :square_offset_x	     , :integer  ],
        [ :square_offset_y	     , :integer  ],
        [ :square_scale_factor	 , :numeric  ]
      ],
      CabooseStore::ProductImageVariant => [
        [ :product_image_id	     , :integer ],
        [ :variant_id	           , :integer ]
      ],
      CabooseStore::Product => [
        [ :title	               , :string    ],
        [ :description	         , :text      ],
        [ :handle	               , :string    ],
        [ :vendor_id	           , :integer   ],
        [ :option1	             , :string    ],
        [ :option2	             , :string    ],
        [ :option3	             , :string    ],
        [ :category_id	         , :integer   ],
        [ :status	               , :string    ],
        [ :default1	             , :string    ],
        [ :default2	             , :string    ],
        [ :default3	             , :string    ],
        [ :seo_title	           , :string    ],
        [ :seo_description	     , :string    ],
        [ :alternate_id	         , :integer   ],
        [ :date_available	       , :datetime  ]
      ],
      CabooseStore::Review => [
        [ :product_id	           , :integer   ],
        [ :content	             , :string    ],
        [ :name	                 , :string    ],
        [ :rating	               , :decimal   ] 
      ],      
      CabooseStore::SearchFilter => [
        [ :url                   , :string   ],
        [ :title_like            , :string   ],
        [ :search_like           , :string   ],
        [ :category_id           , :integer  ],
        [ :category              , :text     ],
        [ :vendors               , :text     ],
        [ :option1               , :text     ],
        [ :option2               , :text     ],
        [ :option3               , :text     ],        
        [ :prices                , :text     ] 
      ],
      CabooseStore::Variant => [
        [ :sku	                 , :string   ],
        [ :barcode	             , :string   ],
        [ :price	               , :numeric  ],
        [ :available	           , :boolean  ],
        [ :quantity_in_stock	   , :integer  ],
        [ :ignore_quantity       , :boolean  ],
        [ :allow_backorder	     , :boolean  ],
        [ :weight	               , :decimal  ],
        [ :length	               , :decimal  ],
        [ :width	               , :decimal  ],
        [ :height	               , :decimal  ],
        [ :cylinder	             , :boolean  ],
        [ :option1	             , :string   ],
        [ :option2	             , :string   ],
        [ :option3	             , :string   ],
        [ :requires_shipping	   , :boolean  ],
        [ :taxable	             , :boolean  ],
        [ :product_id	           , :integer  ],
        [ :shipping_unit_value	 , :numeric  ],
        [ :alternate_id	         , :integer  ],
        [ :status	               , :string   ]
      ],
      CabooseStore::Vendor => [
        [ :name	  , :string ],
        [ :status , :string, { default: 'Active' } ]
      ]
    }
  end
  
  def self.load_data
    if !CabooseStore::Category.exists?(1)
      CabooseStore::Category.create({ :id => 1, :name => 'All Products', :url => '/products', :slug => 'products' })
    end
    if !CabooseStore::Vendor.exists?(1)
      CabooseStore::Vendor.create({ :id => 1, :name => 'Unknown' })
    end      
  end
  
end
