module CabooseStore
  class CategoriesController < CabooseStore::ApplicationController  
    
    #=============================================================================
    # Admin actions
    #=============================================================================
    
    # GET /admin/categories
    def admin_index
      return if !user_is_allowed('categories', 'view')
      @top_category = Category.find(1)         
      render :layout => 'caboose/admin'
    end
      
    # GET /admin/categories/:id/edit
    def admin_edit
      return if !user_is_allowed('categories', 'edit')    
      @category = Category.find(params[:id])
      render :layout => 'caboose/admin'
    end        
    
    # PUT /admin/categories/:id
    def admin_update
      return if !user_is_allowed('categories', 'edit')
      
      resp = Caboose::StdClass.new({'attributes' => {}})
      cat = Category.find(params[:id])    
      
      save = true    
      params.each do |name,value|
        case name
          when 'name'
            cat.name = value
          when 'slug'
            cat.slug = value
            cat.url = cat.parent ? "#{cat.parent.url}/#{cat.slug}" : "/#{cat.slug}"
            update_child_category_slugs(cat)          
          when 'square_offset_x'
            cat.square_offset_x = value
          when 'square_offset_y'
            cat.square_offset_y = value
          when 'square_scale_factor'
            cat.square_scale_factor = value
          when 'image'
            cat.image = value                
        end
      end
      resp.success = save && cat.save
      if params[:image]
        resp.attributes['image'] = { 'value' => cat.image.url(:medium) }
      end
      render json: resp
    end
    
    def update_child_category_slugs(cat)
      return if cat.children.nil?
      return if cat.children.count == 0
      cat.children.each do |kid|
        kid.url = "#{cat.url}/#{kid.slug}"
        kid.save
        update_child_category_slugs(kid)
      end
    end
    
    # GET /admin/categories/new
    def admin_new
      return if !user_is_allowed('categories', 'add')
      @top_category = Category.find(1)
      render :layout => 'caboose/admin'
    end
    
    # POST /admin/categories
    def admin_add
      return if !user_is_allowed('categories', 'add')
      
      resp = Caboose::StdClass.new(
        :error => nil,
        :redirect => nil
      )    
      parent_id = params[:parent_id]
      name      = params[:name]
      
      if parent_id == ''
        resp.error = "Please select a parent category."
      elsif name.length == 0
        resp.error = "The title cannot be empty."
      else
        cat = Category.new
        cat.parent_id = parent_id
        cat.name = name      
        cat.slug = Category.get_slug(cat.name) 
        cat.save
        cat.url = cat.parent ? "#{cat.parent.url}/#{cat.slug}" : "/#{cat.slug}"
        cat.save
        resp.redirect = "/admin/categories/#{cat.id}/edit"
      end
      render :json => resp    
    end
    
    # DELETE /admin/categories/:id
    def admin_delete
      return if !user_is_allowed('categories', 'delete')
      
      resp = Caboose::StdClass.new(
        :error => nil,
        :redirect => nil
      )
      
      cat = Category.find(params[:id])
      if cat.products && cat.products.count > 0
        resp.error = "You can't delete a category that has products in it."
      elsif cat.children && cat.children.count > 0
        resp.error = "You can't delete a category that has child categories."
      else
        cat.destroy
        resp.redirect = '/admin/categories'
      end
        
      render :json => resp
    end
    
    # GET /admin/categories/options
    def admin_options
      return if !user_is_allowed('categories', 'view')
      render :json => Category.options    
    end
  end
end
