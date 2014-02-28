module CabooseStore
  module ProductsHelper
    
    def category_options(top_categories, selected_id = nil)
      arr = []
      top_categories.each do |cat|
        category_options_helper(cat, selected_id, arr)
      end
      return arr.join("\n")        
    end
    
    def category_options_helper(cat, selected_id, arr, prefix = "")
      opt = "<option value='#{cat.id}'"
      opt << " selected='true'" if !selected_id.nil? && selected_id == cat.id
      opt << ">#{prefix}#{cat.name}</option>"
      arr << opt
      cat.children.each do |cat2|
        category_options_helper(cat2, selected_id, arr, "#{prefix} - ")
      end
    end
    
    def category_checkboxes(top_categories, selected_ids = nil)
      str = "<ul>"
      top_categories.each do |cat|
        category_checkboxes_helper(cat, selected_ids, str)
      end
      str << "</ul>"
      return str
    end
    
    def category_checkboxes_helper(cat, selected_ids, str, prefix = "")
      str << "<li>"
      if cat.children && cat.children.count > 0
        str << "<input type='checkbox' id='cat_#{cat.id}' value='#{cat.id}'"
        str << " checked='true'" if selected_ids && selected_ids.include?(cat.id)
        str << "> <label for='cat_#{cat.id}'><h3>#{cat.name}</h3></label>"
      else
        str << "<input type='checkbox' id='cat_#{cat.id}' value='#{cat.id}'"
        str << " checked='true'" if selected_ids && selected_ids.include?(cat.id)
        str << "> <label for='#{cat.id}'>#{cat.name}</label>"
      end
      cat.children.each do |cat2|
        str << "<ul>"
        category_checkboxes_helper(cat2, selected_ids, str, "#{prefix}&nbsp;&nbsp;")
        str << "</ul>"
      end
      str << "</li>"
    end
    
    def product_price(p)
      price = ""
      if p.price_varies
        arr = p.price_range
        min = number_to_currency(arr[0], :precision => 2)
        max = number_to_currency(arr[1], :precision => 2)
        if min.eql? max
          price = "#{min}"
        else
          price = "#{min}-#{max}"
        end
      else
        price = p.variants[0].price
        price = number_to_currency(price, :precision => 2)
      end
      return price
    end
    
    def breadcrumb(p)
      return p.category.ancestry.collect{|cat| "<li><a href='/products/#{cat.id}'>#{cat.name}</a></li>"}.join("<span class='divider'>/</span>")
    end
    
    #def product_thumb(product, price)    
    #  style = square_image(product.featured_image)
  	#	price = product.most_popular_variant.price if price.nil?
  	#
  	#	str = "<li class='thumb'>"
  	#	str << "<a href='/products/#{product.id}'>"
  	#	str << "<figure class='thumb-image' style='<%= style %>"></figure>"
  	#	str << "<div class="thumb-title"><%= product.title %></div>"
  	#	str << "  <div class="thumb-price"><%= price %></div>"
  	#	str << "</a>"
  	#	str << "</li><!-- .thumb -->"
    #
    #end
     
  end
end
