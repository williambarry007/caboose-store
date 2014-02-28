module CabooseStore
  class VariantsController < ApplicationController  
      
    #=============================================================================
    # Admin actions
    #=============================================================================
       
    # GET /admin/variants/:variant_id/edit
    # GET /admin/products/:product_id/variants/:variant_id/edit
    def admin_edit
      return if !user_is_allowed('variants', 'edit')    
      @variant = Variant.find(params[:variant_id])
      @product = @variant.product
      render :layout => 'caboose/admin'
    end
      
    # PUT /admin/variants/:id
    def admin_update
      return if !user_is_allowed('variants', 'edit')
      
      resp = Caboose::StdClass.new({'attributes' => {}})
      v = Variant.find(params[:id])    
      
      save = true    
      params.each do |name,value|
        case name        
          when 'alternate_id'
            v.alternate_id = value
          when 'sku'
            v.sku = value
          when 'barcode'
            v.barcode = value
          when 'price'
            v.price = value
          when 'quantity_in_stock'
            v.quantity_in_stock = value
          when 'allow_backorder'
            v.allow_backorder = value
          when 'status'
            v.status = value
          when 'weight'
            v.weight = value
          when 'length'
            v.length = value
          when 'width'
            v.width = value
          when 'height'
            v.height = value
          when 'option1'
            v.option1 = value
          when 'option2'
            v.option2 = value
          when 'option3'
            v.option3 = value
          when 'requires_shipping'
            v.requires_shipping = value
          when 'taxable'
            v.taxable = value
        end
      end
      resp.success = save && v.save
      render :json => resp
    end
    
    # GET /admin/products/:id/variants/new
    def admin_new
      return if !user_is_allowed('variants', 'add')
      @top_categories = ProductCategory.where(:parent_id => nil).reorder('name').all
      @product_id = params[:id] 
      @variant = Variant.new
      render :layout => 'caboose/admin'
    end
    
    # POST /admin/products/:id/variants
    def admin_add
      return if !user_is_allowed('variants', 'add')
      resp = Caboose::StdClass.new(
        :error => nil,
        :refresh => nil
      )
      
      p = Product.find(params[:id])
      v = Variant.new(:product_id => p.id)
      v.option1 = p.default1
      v.option2 = p.default2
      v.option3 = p.default3
      v.status  = 'Active'
      v.save
      resp.refresh = true
      render :json => resp
    end
    
    # PUT /admin/variants/:id/attach-to-image
    def admin_attach_to_image
      render :json => false if !user_is_allowed('variants', 'edit')         
      variant_id = params[:id].to_i
      img = ProductImage.find(params[:product_image_id])
  
      exists = false
      img.variants.each do |v|
        if v.id == variant_id
          exists = true
          break
        end
      end
      if exists
        render :json => true
        return
      end
      
      img.variants = [] if img.variants.nil?
      img.variants << Variant.find(variant_id)
      img.save
      
      render :json => true
    end
    
    # PUT /admin/variants/:id/unattach-from-image
    def admin_unattach_from_image
      render :json => false if !user_is_allowed('variants', 'edit')
      v = Variant.find(params[:id])
      img = ProductImage.find(params[:product_image_id])       
      img.variants.delete(v)
      img.save
      render :json => true
    end
    
    # DELETE /admin/variants/:id
    def admin_delete
      return if !user_is_allowed('variants', 'delete')
      v = Variant.find(params[:id])
      v.status = 'Deleted'
      v.save
      render :json => Caboose::StdClass.new({
        :redirect => "/admin/products/#{v.product_id}/variants"
      })
    end
    
    # GET /admin/variants/status-options
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
    
  end
end
