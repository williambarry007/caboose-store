module CabooseStore
  module ProductsHelper
    def active_products
      CabooseStore::Product.active
    end
    
    def caboose_sort_options
      render :partial => '/caboose_store/products/sort_options'
    end
  end
end
