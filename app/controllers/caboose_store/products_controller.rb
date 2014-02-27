module CabooseStore
  class ProductsController < ApplicationController  
    
    # GET /products/
    def index      
      #render :text => params
      
      ## Try to get the category
      #url2 = request.fullpath.split("?")[0]
      #@category = nil
      #if Category.exists?(:url => url2)
      #  @category = Category.where(:url => url2).first        
      #  @category = Category.find(@category.parent_id) if @category && (@category.children.nil? || @category.children.count == 0)
      #end
      
      # If looking at single item
      if params[:id] && Product.exists?(params[:id])        
        @product = Product.find(params[:id])
        
        if @product.status == 'Inactive'
          render 'products/not_available'
          return
        end
          
        @review = Review.new                
        @reviews = Review.where(:product_id => @product.id).limit(10).order("id DESC") || nil
        @logged_in_user = logged_in_user
                    
        render 'caboose_store/products/details'
        return
      end
          
      # Otherwise looking at a category or search parameters
      @pager = Caboose::PageBarGenerator.new(params, {      
          'category_id'       => '',
          'category_slug'     => '',
          'title_like'        => '',
          'description_like'  => '',
          'vendor_id'         => '',
          'price_gte'         => '',
          'price_lte'         => '',
          'sku_like'          => ''
        },{
          'model'       => 'CabooseStore::Product',                    
          'includes'    => {
            'category_id'   => ['categories' , 'id'    ],
            'category_slug' => ['categories' , 'slug'  ],
            'price_gte'     => ['variants'   , 'price' ],
            'price_lte'     => ['variants'   , 'price' ],
            'sku_like'      => ['variants'   , 'sku'   ]
          },
          'abbreviations' => {
            'category_slug'    => 'category',
            'title_like'       => 'title',
            'description_like' => 'desc',
            'vendor_id'        => 'vid',
            'sku_like'         => 'sku'            
          },          
          'sort'        => 'title',
          'desc'        => false,
          'base_url'    => '/products',
          'items_per_page' => 15,
          'skip' => ['category_id']
        })      
        
      @filter = SearchFilter.find_from_url(request.fullpath, @pager, ['page'])         
      #@pager.params['category_id'] = @filter.category_id ? @filter.category_id : ''
      
      @pager.set_item_count
      @products = @pager.items
      @category = @filter.category ? Category.find(@filter.category.id) : nil
            
    end
  
    def show      
    end
    
    #=============================================================================
    # Admin actions
    #=============================================================================
    
    # GET /admin/products
    def admin_index
      return if !user_is_allowed('products', 'view')
        
      @gen = Caboose::PageBarGenerator.new(params, {
          'title_like'    => '',
          'id'            => ''
      },{
          'model'       => 'CabooseStore::Product',
          'sort'        => 'title',
          'desc'        => false,
          'base_url'    => '/admin/products'
      })
      @products = @gen.items    
      render :layout => 'caboose/admin'
    end
      
    # GET /admin/products/:id/general
    def admin_edit_general
      return if !user_is_allowed('products', 'edit')    
      @product = Product.find(params[:id])
      render :layout => 'caboose/admin'
    end
    
    # GET /admin/products/:id/description
    def admin_edit_description   
      return if !user_is_allowed('products', 'edit')    
      @product = Product.find(params[:id])
      render :layout => 'caboose/admin'
    end
    
    # GET /admin/products/:id/variants
    # GET /admin/products/:id/variants/:variant_id
    def admin_edit_variants   
      return if !user_is_allowed('products', 'edit')    
      @product = Product.find(params[:id])
      if @product.variants.nil? || @product.variants.count == 0
        v = Variant.new
        v.option1 = @product.default1 if @product.option1
        v.option2 = @product.default2 if @product.option2
        v.option3 = @product.default3 if @product.option3
        @product.variants = [v]
        @product.save
      end
      @variant = params[:variant_id] ? Variant.find(params[:variant_id]) : @product.variants[0]
      session['variant_cols'] = self.default_variant_cols if session['variant_cols'].nil?
      @cols = session['variant_cols']
      
      if @product.options.nil? || @product.options.count == 0
        render 'products/admin_edit_variants_single', :layout => 'caboose/admin'  
      else
        render 'products/admin_edit_variants', :layout => 'caboose/admin'
      end          
    end
    
    # GET /admin/products/:id/variants/json
    def admin_variants_json
      render :json => false if !user_is_allowed('products', 'edit')    
      p = Product.find(params[:id])
      render :json => p.variants
    end
    
    # GET /admin/products/:id/variant-cols  
    def admin_edit_variant_columns
      return if !user_is_allowed('products', 'edit')    
      @product = Product.find(params[:id])
      session['variant_cols'] = self.default_variant_cols if session['variant_cols'].nil?
      @cols = session['variant_cols']
      render :layout => 'caboose/admin'
    end
    
    # PUT /admin/products/:id/variant-cols
    def admin_update_variant_columns    
      return if !user_is_allowed('products', 'edit')
      session['variant_cols'] = self.default_variant_cols if session['variant_cols'].nil?
      
      resp = Caboose::StdClass.new({'attributes' => {}})
      product = Product.find(params[:id])    
      
      save = true    
      params.each do |name,value|
        value = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(value)
        case name
          when 'option1'        ,
            'option2'           ,
            'option3'           ,
            'status'            ,
            'alternate_id'      ,
            'sku'               ,                        
            'barcode'           , 
            'price'             ,
            'quantity_in_stock' ,
            'weight'            , 
            'length'            , 
            'width'             , 
            'height'            , 
            'cylinder'          , 
            'requires_shipping' ,
            'allow_backorder'   ,
            'taxable'      
            session['variant_cols'][name] = value
        end
      end
      resp.success = save && product.save
      render :json => resp
    end
    
    def default_variant_cols
      return {    
        'option1'           => true,
        'option2'           => true,
        'option3'           => true,
        'status'            => true,
        'alternate_id'      => true,
        'sku'               => true,                         
        'barcode'           => false, 
        'price'             => true, 
        'quantity_in_stock' => true, 
        'weight'            => false, 
        'length'            => false, 
        'width'             => false, 
        'height'            => false, 
        'cylinder'          => false, 
        'requires_shipping' => false,
        'allow_backorder'   => false,
        'taxable'           => false
      }
    end
    
    # GET /admin/products/:id/options
    def admin_edit_options
      return if !user_is_allowed('products', 'edit')    
      @product = Product.find(params[:id])
      render :layout => 'caboose/admin'          
    end
    
    # GET /admin/products/:id/categories
    def admin_edit_categories
      return if !user_is_allowed('products', 'edit')
      @product = Product.find(params[:id])
      @top_categories = Category.where(:parent_id => 1).reorder('name').all
      @selected_ids = @product.categories.collect{ |cat| cat.id }
      render :layout => 'caboose/admin'
    end
    
    # POST /admin/products/:id/categories
    def admin_add_to_category
      return if !user_is_allowed('products', 'edit')
      cat_id = params[:category_id]
      product_id = params[:id]
      
      if !CategoryMembership.exists?(:category_id => cat_id, :product_id => product_id)
        CategoryMembership.create(:category_id => cat_id, :product_id => product_id)
      end    
      render :json => true
    end
    
    # DELETE /admin/products/:id/categories/:category_id
    def admin_remove_from_category
      return if !user_is_allowed('products', 'edit')
      cat_id = params[:category_id]
      product_id = params[:id]
      
      if CategoryMembership.exists?(:category_id => cat_id, :product_id => product_id)
        CategoryMembership.where(:category_id => cat_id, :product_id => product_id).destroy_all
      end        
      render :json => true
    end
    
    # GET /admin/products/:id/images
    def admin_edit_images    
      return if !user_is_allowed('products', 'edit')    
      @product = Product.find(params[:id])
      render :layout => 'caboose/admin'
    end
    
    # POST /admin/products/:id/images
    def admin_add_image
      return if !user_is_allowed('products', 'edit')
      product_id = params[:id]
      
      if (params[:new_image].nil?)
        render :text => "<script type='text/javascript'>parent.modal.autosize(\"<p class='note error'>You must provide an image.</p>\", 'new_image_message');</script>"
      else    
        img = ProductImage.new
        img.product_id = product_id
        img.image = params[:new_image]
        img.square_offset_x = 0
        img.square_offset_y = 0
        img.square_scale_factor = 1.00
        img.save
        render :text => "<script type='text/javascript'>parent.window.location.reload(true);</script>"
      end
    end
    
    # GET /admin/products/:id/collections
    def admin_edit_collections
      return if !user_is_allowed('products', 'edit')    
      @product = Product.find(params[:id])
      render :layout => 'caboose/admin'
    end    
    
    # GET /admin/products/:id/seo
    def admin_edit_seo
      return if !user_is_allowed('products', 'edit')    
      @product = Product.find(params[:id])
      render :layout => 'caboose/admin'
    end
    
    # GET /admin/products/:id/delete
    def admin_delete_form
      return if !user_is_allowed('products', 'edit')    
      @product = Product.find(params[:id])
      render :layout => 'caboose/admin'
    end
      
    # PUT /admin/products/:id
    def admin_update
      return if !user_is_allowed('products', 'edit')
      
      resp = Caboose::StdClass.new({'attributes' => {}})
      product = Product.find(params[:id])    
      
      save = true    
      params.each do |name,value|
        case name
          when 'alternate_id'
            product.alternate_id = value
          when 'date_available'
            if value.strip.length == 0
              product.date_available = nil
            else
              begin
                product.date_available = DateTime.parse(value)            
              rescue
                resp.error = "Invalid date"
                save = false
              end
            end
          when 'title'
            product.title = value
          when 'description'
            product.description = value
          when 'category_id'
            product.category_id = value
          when 'vendor_id'  
            product.vendor_id = value
          when 'handle'
            product.handle = value
          when 'seo_title'
            product.seo_title = value
          when 'seo_description'
            product.seo_description = value
          when 'option1'
            product.option1 = value
          when 'option2'
            product.option2 = value
          when 'option3'
            product.option3 = value
          when 'default1'
            product.default1 = value
            Variant.where(:product_id => product.id, :option1 => nil).each do |p|
              p.option1 = value
              p.save
            end
          when 'default2'
            product.default2 = value
            Variant.where(:product_id => product.id, :option2 => nil).each do |p|
              p.option2 = value
              p.save
            end
          when 'default3'
            product.default3 = value
            Variant.where(:product_id => product.id, :option3 => nil).each do |p|
              p.option3 = value
              p.save
            end
          when 'status'
            product.status = value
        end
      end
      resp.success = save && product.save
      render :json => resp
    end
    
    # GET /admin/products/new
    def admin_new
      return if !user_is_allowed('products', 'add')    
      render :layout => 'caboose/admin'
    end
    
    # POST /admin/products
    def admin_add
      return if !user_is_allowed('products', 'add')
      
      resp = Caboose::StdClass.new(
        :error => nil,
        :redirect => nil
      )
      
      title = params[:title]
      
      if title.length == 0
        resp.error = "The title cannot be empty."
      else
        p = Product.new(:title => title)
        p.save
        resp.redirect = "/admin/products/#{p.id}/general"
      end
      render :json => resp    
    end
    
    # DELETE /admin/products/:id
    def admin_delete
      return if !user_is_allowed('products', 'delete')
      p = Product.find(params[:id]).destroy
      p.status = 'Deleted'
      p.save
      render :json => Caboose::StdClass.new({
        :redirect => '/admin/products'
      })
    end
    
    # GET /admin/products/status-options
    def admin_status_options
      arr = ['Active', 'Inactive', 'Deleted']
      options = []
      arr.each do |status|
        options << {
          :value => status,
          :text => status
        }
      end
      render :json => options
    end
    
    # GET /admin/products/combine
    def admin_combine_select_products
    end
    
    # GET /admin/products/combine-step2
    def admin_combine_assign_title
    end
    
    # POST /admin/products/combine
    def admin_combine
      product_ids = params[:product_ids]
      
      p = Product.new
      p.title       = params[:title]
      p.description = params[:description]
      p.option1     = params[:option1]
      p.option2     = params[:option2]
      p.option3     = params[:option3]      
      p.default1    = params[:default1]
      p.default2    = params[:default2]
      p.default3    = params[:default3]
      p.status      = 'Active'
      p.save
      
      
      
      product_ids.each do |pid|
        p = Product.find(pid)
        p.variants.each do |v|
        end
      end
        
      
    end
    
  end
end
