module CabooseStore
  class CartController < CabooseStore::ApplicationController
    before_filter :get_line_item, :except => [:list]
    
    def get_line_item
      @line_item = if params[:id]
        @order.line_items.find(params[:id])
      elsif params[:variant_id]
        @order.line_items.find_by_variant_id(params[:variant_id])
      end
    end
    
    # GET /cart/items
    def index
      respond_to do |format|
        format.html
        format.json { render :json => { :order => @order } }
      end
    end
    
    # POST /cart/add
    def add
      @line_item ||= LineItem.create(
        :order_id => @order.id,
        :variant_id => params[:variant_id]
      )
      
      @line_item.quantity += params[:quantity] ? params[:quantity].to_i : 1
      render :json => { :success => @line_item.save, :errors => @line_item.errors.full_messages }
    end
    
    # PUT cart/update
    def update
      @line_item.quantity = params[:quantity].to_i
      render :json => { :success => @line_item.save, :errors => @line_item.errors.full_messages, :line_item => @line_item  }
    end
    
    # DELETE cart/delete
    def remove
      @order.line_items.delete(@line_item)
      render :json => { :success => !!@line_item.destroy }
    end
  end
end

