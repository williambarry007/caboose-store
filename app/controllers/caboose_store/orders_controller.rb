module CabooseStore
  class OrdersController < ApplicationController
      
    helper :authorize_net
    protect_from_forgery :except => :authnet_relay_response
    
    # GET /admin/orders
    def admin_index
      return if !user_is_allowed('orders', 'view')
  
      @gen = Caboose::PageBarGenerator.new(params, {
          'customer_id'           => '', 
          'status'                => 'pending',
          'shipping_method_code'  => '',
          'id'                    => ''
      },{
          'model'       => 'CabooseStore::Order',
          'sort'        => 'id',
          'desc'        => 1,
          'base_url'    => '/admin/orders'
      })    
      @orders = @gen.items
      @customers = Caboose::User.reorder('last_name, first_name').all
      render :layout => 'caboose/admin'
    end
    
    # GET /admin/orders/new
    def admin_new
      return if !user_is_allowed('orders', 'add')       
      @products = Product.reorder('title').all    
      render :layout => 'caboose/admin'
    end
      
    # GET /admin/orders/:id
    def admin_edit
      return if !user_is_allowed('orders', 'edit')    
      @order = Order.find(params[:id])
      render :layout => 'caboose/admin'
    end
    
    # GET /admin/orders/:id/json
    def admin_json
      return if !user_is_allowed('orders', 'edit')    
      order = Order.find(params[:id])
      render :json => order, :include => { :order_line_items => { :include => :variant }}
    end
  
    # GET /admin/orders/:id/print
    def admin_print
      return if !user_is_allowed('orders', 'edit')    
       
      pdf = OrderPdf.new
      pdf.order = Order.find(params[:id])             
      send_data pdf.to_pdf, filename: "order_#{pdf.order.id}.pdf", type: "application/pdf", disposition: "inline"
      
      #@order = Order.find(params[:id])
      #render :layout => 'caboose/admin'
    end
      
    # PUT /admin/orders/:id
    def admin_update
      return if !user_is_allowed('orders', 'edit')
      
      resp = Caboose::StdClass.new({'attributes' => {}})
      order = Order.find(params[:id])    
      
      save = true    
      params.each do |name,value|
        case name
          when 'tax'
            order.tax = value          
          when 'shipping'
            order.shipping = value
          when 'handling'
            order.handling = value
          when 'discount'
            order.discount = value        
          when 'status'
            order.status = value
            resp.attributes['status'] = {'text' => value}
        end
      end
      order.calculate_total    
      resp.success = save && order.save
      render :json => resp
    end
    
    # PUT /admin/orders/:order_id/line-items/:id
    def admin_update_line_item
      return if !user_is_allowed('orders', 'edit')
      
      resp = Caboose::StdClass.new({'attributes' => {}})
      li = OrderLineItem.find(params[:id])    
      
      save = true
      send_status_email = false    
      params.each do |name,value|
        case name
          when 'quantity'
            li.quantity = value
            li.save
                      	  
            # Recalculate everything
            r = ShippingCalculator.rate(li.order, li.order.shipping_method_code)
            li.order.shipping = r['negotiated_rate'] / 100
            li.order.handling = (r['negotiated_rate'] / 100) * 0.05
            tax_rate = TaxCalculator.tax_rate(li.order.shipping_address)
            li.order.tax = li.order.subtotal * tax_rate
            li.order.calculate_total
            li.order.save
            
          when 'tracking_number'
            li.tracking_number = value
            send_status_email = true
          when 'status'
            li.status = value
            resp.attributes['status'] = {'text' => value}
            send_status_email = true
        end
      end
      if send_status_email       
        OrdersMailer.customer_status_updated(li.order).deliver
      end
      resp.success = save && li.save
      render :json => resp
    end 
    
    # DELETE /admin/orders/:id
    def admin_delete
      return if !user_is_allowed('orders', 'delete')
      Order.find(params[:id]).destroy
      render :json => Caboose::StdClass.new({
        :redirect => '/admin/orders'
      })
    end
    
    # GET /admin/orders/line-item-status-options
    def admin_line_item_status_options
      arr = ['pending', 'ready to ship', 'shipped', 'backordered', 'canceled']
      options = []
      arr.each do |status|
        options << {
          :value => status,
          :text => status
        }
      end
      render :json => options
    end
    
    # GET /admin/orders/:id/capture
    def capture_funds
      return if !user_is_allowed('orders', 'edit')
      
      resp = Caboose::StdClass.new({
        'refresh' => nil,
        'error' => nil,
        'success' => nil
      })
      
      order = Order.find(params[:id])
      if order.financial_status == 'captured'
        resp.error = "Funds for this order have already been captured."    
      elsif order.total > order.auth_amount
        resp.error = "The order total exceeds the authorized amount."
      else      
        trans = AuthorizeNet::AIM::Transaction.new(
          AUTHORIZE_NET_CONFIG['api_login_id'], 
          AUTHORIZE_NET_CONFIG['api_transaction_key'],          
          :gateway => :production
          #:test => true
        )
        amount = order.total < order.auth_amount ? order.total : nil
        r = trans.prior_auth_capture(order.transaction_id, amount)
        Caboose.log(r.inspect)
        if r.success?
          order.financial_status = 'captured'
          order.save
          resp.success = "Captured funds successfully."
        else        
          if r.connection_failure?
            resp.error = "Error connecting to authorize.net."
          else
            resp.error = "Error capture funds."
          end
        end
      end
      render :json => resp
    end
    
    # GET /admin/orders/:id/send-to-quickbooks
    def admin_send_to_quickbooks
      return if !user_is_allowed('orders', 'edit')
      
      resp = Caboose::StdClass.new({
        'refresh' => nil,
        'success' => nil,
        'error' => nil
      })
      order = Order.find(params[:id])    
      Quickbooks.create_order(order)
      resp.success = "Order sent to quickbooks successfully."
      render :json => resp
    end
    
    # GET /admin/orders/status-options
    def admin_status_options
      return if !user_is_allowed('categories', 'view')
      statuses = ['cart', 'pending', 'ready to ship', 'shipped', 'canceled']
      options = []
      statuses.each do |s|
        options << {
          'text' => s,
          'value' => s
        }
      end       
      render :json => options    
    end
    
    # GET  /admin/orders/authnet-relay-response
    # POST /admin/orders/authnet-relay-response  
    #def authnet_relay_response
    #  sim_response = AuthorizeNet::SIM::Response.new(params)
    #  if sim_response.success?(AUTHORIZE_NET_CONFIG['api_login_id'], AUTHORIZE_NET_CONFIG['merchant_hash_value'])      
    #    if (params[:x_response_code].to_i == 1) # Approved
    #      order = Order.find(params[:x_invoice_num])
    #      order.date_captured = DateTime.now        
    #      order.financial_status = 'captured'        
    #      order.save        
    #    end      
    #  end
    #  render :text => sim_response.direct_post_reply('https://tuskwearadmin.herokuapp.com/admin/orders/authnet-receipt', :include => true)
    #end
    
    # GET /admin/orders/authnet-receipt
    #def authnet_receipt
    #  return if !user_is_allowed('orders', 'edit')
    #  
    #  resp = Caboose::StdClass.new({
    #    'refresh' => nil,
    #    'error' => nil
    #  })
    #  
    #  if (params[:x_response_code].to_i == 1) # Approved
    #    resp.refresh = true
    #  else 
    #    resp.error = "There was an error capture funds:<br /><br />#{params[:x_response_reason_text]}"      
    #  end
    #  render :text => "<script type='text/javascript'>parent.capture_funds_response(#{resp.to_json});</script>"
    #end
    
    # GET /admin/orders/test-info
    def admin_mail_test_info
      TestMailer.test_info.deliver
      render :text => "Sent email to info@tuskwearcollection.com on #{DateTime.now.strftime("%F %T")}"
    end
    
    # GET /admin/orders/test-gmail
    def admin_mail_test_gmail
      TestMailer.test_gmail.deliver
      render :text => "Sent email to william@nine.is on #{DateTime.now.strftime("%F %T")}"
    end
    
    # GET /admin/orders/google-feed
    def admin_google_feed
      d2 = DateTime.now
      d1 = DateTime.now
      if Caboose::Setting.exists?(:name => 'google_feed_date_last_submitted')                  
        d1 = Caboose::Setting.where(:name => 'google_feed_date_last_submitted').first.value      
        d1 = DateTime.parse(d1)
      elsif Order.exists?("status = 'shipped' and date_authorized is not null")
        d1 = Order.where("status = ? and date_authorized is not null", 'shipped').reorder("date_authorized DESC").limit(1).pluck('date_authorized')
        d1 = DateTime.parse(d1)
      end
      
      # Google Feed Docs
      # https://support.google.com/trustedstoresmerchant/answer/3272612?hl=en&ref_topic=3272286?hl=en
      tsv = ["merchant order id\ttracking number\tcarrier code\tother carrier name\tship date"]            
      if Order.exists?("status = 'shipped' and date_authorized > '#{d1.strftime("%F %T")}'")
        Order.where("status = ? and date_authorized > ?", 'shipped', d1).reorder(:id).all.each do |order|
          tracking_numbers = order.line_items.collect{ |li| li.tracking_number }.compact.uniq
          tn = tracking_numbers && tracking_numbers.count >= 1 ? tracking_numbers[0] : ""
          tsv << "#{order.id}\t#{tn}\tUPS\t\t#{order.date_shipped.strftime("%F")}"                              
        end
      end
      
      # Save when we made the last call
      setting = Caboose::Setting.exists?(:name => 'google_feed_date_last_submitted') ? 
        Caboose::Setting.where(:name => 'google_feed_date_last_submitted').first
        Caboose::Setting.new(:name => 'google_feed_date_last_submitted')
      setting.value = d2.strftime("%F %T")
      setting.save            
                   
      # Print out the lines
      render :text => tsv.join("\n")
      
    end
    
  end
end
