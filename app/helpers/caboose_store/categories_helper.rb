module CabooseStore
  module CategoriesHelper
    def root_category
      CabooseStore::Category.root
    end
    
    def top_level_categories
      CabooseStore::Category.top_level
    end
    
    def category_list(category=root_category)
      content_tag :ul, category_list_items(category)
    end
    
    def category_list_items(category)
      
      # Link to category
      link = link_to(category.name, "/admin/categories/#{category.id}/edit")
      
      # Recursively find category children
      children = content_tag :ul, category.children.collect { |child| category_list_items(child) }.join.to_s.html_safe if category.children.any?
      
      # Return the list item
      content_tag :li, link.concat(children)
    end
    
    def category_select(form_name, category=root_category, selected_id=nil)
      
      # Collect all recursive options from specified category down
      options = category_options(category, selected_id)
      
      # Prepend the root category
      options.unshift([category.name, category.id])
      
      # Create select tag
      select_tag form_name, options_for_select(options)
    end
    
    def category_options(category, selected_id, prefix="")
      
      # Array to hold options
      options = Array.new
      
      # Recusively tterate over all child categories
      category.children.collect do |child|
        options << ["#{prefix} - #{child.name}", child.id]
        options.concat category_options(child, selected_id, "#{prefix} -")
      end
      
      # Return the options array
      return options
    end
  end
end
