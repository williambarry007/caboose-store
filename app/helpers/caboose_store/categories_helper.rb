module CabooseStore
  module CategoriesHelper
                    
    def categories_tree(cat)
      str = "<ul>"
      str << categories_tree_helper(cat)
      str << "</ul>"
      return str
    end
    
    def categories_tree_helper(cat)        
      str = "<li><a href='/admin/categories/#{cat.id}/edit'>#{cat.name}</a>"
      if cat.children && cat.children.count > 0
        str << "<ul>"
        cat.children.each { |kid| str << categories_tree_helper(kid) }
        str << "</ul>"
      end
      str << "</li>\n"
      return str
    end
    
    def categories_options(cat, selected_id = nil)    
      str = categories_options_helper(cat, '', selected_id)
      return str
    end
    
    def categories_options_helper(cat, prefix, selected_id)
      str = "<option value='#{cat.id}'"
      str << " selected='true'" if cat.id == selected_id
      str << ">#{prefix}#{cat.name}</option>"
      if cat.children
        cat.children.each { |kid| str << categories_options_helper(kid, "#{prefix} - ", selected_id) }
      end
      return str
    end
    
  end
end