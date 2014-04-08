module CabooseStore
  module ProductsHelper
    def active_products
      CabooseStore::Product.active
    end
  end
end
