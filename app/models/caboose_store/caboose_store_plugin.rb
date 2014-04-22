module CabooseStore
  class CabooseStorePlugin < Caboose::CaboosePlugin
    def self.admin_nav(nav, user=nil, page=nil)
      return nav if user.nil?
      
      item = {
        'id'       => 'general-store',
        'text'     => 'General Store',
        'children' => []
      }
      
      item['children'] << { 'id' => 'categories', 'href' => '/admin/categories' , 'text' => 'Categories'  , 'modal' => false } if user.is_allowed('categories'  , 'view')
      item['children'] << { 'id' => 'products'  , 'href' => '/admin/products'   , 'text' => 'Products'    , 'modal' => false } if user.is_allowed('products'    , 'view')
      item['children'] << { 'id' => 'orders'    , 'href' => '/admin/orders'     , 'text' => 'Orders'      , 'modal' => false } if user.is_allowed('orders'      , 'view')    
      
      nav << item
      
      return nav
    end
    
    def self.javascripts(scripts)
      scripts << 'caboose_store/application'
      
      return scripts
    end
  end
end
