module CabooseStore
  module ApplicationHelper
    
    def foo
      "foobar"
    end
    
    def all_categories()
      list = ""
      top_cats = Category.where(:parent_id => 1).where("id != ?", 32).where("id != ?", 3).reorder('name').limit(3)
      accessories = Category.find(3)
      top_cats << accessories
      top_cats.each do |cat|      
        list << "<li><a href='#{cat.url}'>#{cat.name}</a>"      
        list << "<ul>"
        
        links = {}
        bottom_cats = Category.where(:parent_id => cat.id).reorder("name").all
        bottom_cats.each do |bcat|
          if bcat.products != []
            links[bcat.name] = "<li><a href='#{bcat.url}'>#{bcat.name}</a></li>"          
          end
        end
        cat.products.where(:status => 'active').each do |p|            
          links[p.title] = "<li><a href='/products/#{p.id}'>#{p.title}</a></li>"
        end      
        links.sort.each { |key,val| list << val }
        
        list << "</ul>"
        list << "</li>"
      end
      return list
    end
  
    def square_image(img)    
      style = ""
      if img
        style = "background-image: url(#{img.url(:thumb)});"
        style << "background-position: #{img.square_offset_x.to_s}px #{img.square_offset_y.to_s}px;"
      else
        style = 'background-image: url(https://dmwwflw4i3miv.cloudfront.net/placeholder.jpg);'
      end
      return style    
    end
  end
end
