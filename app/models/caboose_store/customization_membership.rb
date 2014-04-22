module CabooseStore
  class CustomizationMembership < ActiveRecord::Base
    self.table_name = 'store_customization_memberships'
    
    belongs_to :product
    belongs_to :customization, :class_name => 'CabooseStore::Product'
    
    attr_accessible :product_id, :customization_id
  end
end
