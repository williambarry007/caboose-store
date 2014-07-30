
class CabooseStore::Schema < Caboose::Utilities::Schema
  
  def self.schema
    {  
      CabooseStore::Address => [
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
        [ :parent_id             , :integer   ],
        [ :name                  , :string    ],
        [ :url                   , :string    ],
        [ :slug                  , :string    ],
        [ :image_file_name       , :string    ],
        [ :image_content_type    , :string    ],
        [ :image_file_size       , :integer   ],
        [ :image_updated_at      , :datetime  ],
        [ :square_offset_x       , :integer   ],
        [ :square_offset_y       , :integer   ],
        [ :square_scale_factor   , :numeric   ],
        [ :sort_order            , :integer   ]
      ],
      
      CabooseStore::CategoryMembership => [        
        [ :category_id           , :integer ],
        [ :product_id            , :integer ]      
      ],
      
      CabooseStore::Discount => [
        [ :name                  , :string   ],
        [ :code                  , :string   ],
        [ :amount_current        , :numeric  ],
        [ :amount_total          , :numeric  ],
        [ :amount_flat           , :numeric  ],
        [ :amount_percentage     , :numeric  ],
        [ :no_shipping           , :boolean  ],
        [ :no_tax                , :boolean  ]
      ],
      
      CabooseStore::OrderDiscount => [
        [ :order_id              , :integer ],
        [ :discount_id           , :integer ]
      ],
      
      CabooseStore::LineItem => [
        [ :order_id              , :integer  ],
        [ :variant_id            , :integer  ],
        [ :parent_id             , :integer  ],
        [ :quantity              , :integer   , :default => 0 ],
        [ :status                , :string   ],
        [ :tracking_number       , :string   ],
        #[ :unit_price            , :numeric  ],
        [ :price                 , :numeric   , :default => 0 ],
        [ :notes                 , :text     ],
        [ :custom1               , :string   ],
        [ :custom2               , :string   ],
        [ :custom3               , :string   ]
      ],
      
      CabooseStore::Order => [
        [ :email                 , :string   ],
        [ :order_number          , :string   ],
        [ :subtotal              , :numeric  ],
        [ :tax                   , :numeric  ],
        [ :shipping              , :numeric  ],
        [ :discount              , :numeric  ],
        [ :total                 , :numeric  ],
        [ :customer_id           , :integer  ],
        [ :payment_id            , :integer  ],
        [ :gateway_id            , :integer  ],
        [ :financial_status      , :string   ],
        [ :shipping_address_id   , :integer  ],
        [ :billing_address_id    , :integer  ],
        [ :notes                 , :text     ],
        [ :status                , :string   ],
        [ :date_created          , :datetime ],
        [ :date_authorized       , :datetime ],
        [ :date_captured         , :datetime ],
        [ :date_cancelled        , :datetime ],
        [ :referring_site        , :text     ],
        [ :landing_page          , :string   ],
        [ :landing_page_ref      , :string   ],
        [ :shipping_code         , :string   ],
        [ :handling              , :numeric  ],
        [ :transaction_id        , :string   ],
        [ :auth_code             , :string   ],
        [ :alternate_id          , :integer  ],
        [ :auth_amount           , :numeric  ],
        [ :date_shipped          , :datetime ],
        [ :transaction_id        , :string   ],
        [ :transaction_service   , :string   ],
        [ :amount_discounted     , :numeric  ],
        [ :decremented           , :boolean  ]
      ],
      
      CabooseStore::ProductImage => [
        [ :product_id            , :integer  ],
        [ :title                 , :string   ],
        [ :image_file_name       , :string   ],
        [ :image_content_type    , :string   ],
        [ :image_file_size       , :integer  ],
        [ :image_updated_at      , :datetime ],
        [ :square_offset_x       , :integer  ],
        [ :square_offset_y       , :integer  ],
        [ :square_scale_factor   , :numeric  ]
      ],
      
      CabooseStore::ProductImageVariant => [
        [ :product_image_id      , :integer ],
        [ :variant_id            , :integer ]
      ],
      
      CabooseStore::Product => [
        [ :title                 , :string    ],
        [ :caption               , :string    ],
        [ :description           , :text      ],
        [ :handle                , :string    ],
        [ :vendor_id             , :integer   ],
        [ :option1               , :string    ],
        [ :option2               , :string    ],
        [ :option3               , :string    ],
        [ :category_id           , :integer   ],
        [ :status                , :string    ],
        [ :default1              , :string    ],
        [ :default2              , :string    ],
        [ :default3              , :string    ],
        [ :seo_title             , :string    ],
        [ :seo_description       , :string    ],
        [ :alternate_id          , :string    ],
        [ :date_available        , :datetime  ],
        [ :custom_input          , :text      ],
        [ :sort_order            , :integer   ],
        [ :featured              , :boolean    , :default => false ]
      ],
      
      CabooseStore::Review => [
        [ :product_id            , :integer   ],
        [ :content               , :string    ],
        [ :name                  , :string    ],
        [ :rating                , :decimal   ] 
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
        [ :sku                   , :string   ],
        [ :barcode               , :string   ],
        [ :price                 , :numeric   , :default => 0 ],
        [ :available             , :boolean  ],
        #[ :quantity_in_stock     , :integer  ],
        [ :quantity              , :integer   , :default => 0 ],
        [ :ignore_quantity       , :boolean  ],
        [ :allow_backorder       , :boolean  ],
        [ :weight                , :decimal  ],
        [ :length                , :decimal  ],
        [ :width                 , :decimal  ],
        [ :height                , :decimal  ],
        [ :cylinder              , :boolean  ],
        [ :option1               , :string   ],
        [ :option2               , :string   ],
        [ :option3               , :string   ],
        [ :requires_shipping     , :boolean  ],
        [ :taxable               , :boolean  ],
        [ :product_id            , :integer  ],
        [ :shipping_unit_value   , :numeric  ],
        [ :alternate_id          , :string   ],
        [ :status                , :string   ]
      ],
      
      CabooseStore::Vendor => [
        [ :name   , :string ],
        [ :status , :string, { default: 'Active' } ]
      ],
      
      CabooseStore::CustomizationMembership => [
        [ :product_id       , :integer ],
        [ :customization_id , :integer ]
      ]
    }
  end
  
  def self.load_data
    if !CabooseStore::Category.exists?(1)
      CabooseStore::Category.create({
        id: 1,
        name: 'All Products',
        url: '/products',
        slug: 'products'
      })
    end
  end
end
