require 'active_shipping'
include ActiveMerchant::Shipping

module CabooseStore
  class ShippingCalculator
    
    # Calculates the total cost of shipping
    # Providers can be ups, fedex, or usps
    #
    # padded envelope,  5 lbs, 90210 =>  $7.62
    # padded envelope, 20 lbs, 90210 => $13.99
    # box1           , 20 lbs, 90210 => $20.00
    # box2           , 30 lbs, 90210 => $25.00
    def self.rates(order, service_code = nil)
      
      total = 0.0
      weight = 0.0
      order.line_items.each do |li|
        total = total + (li.variant.shipping_unit_value.nil? ? 0 : li.variant.shipping_unit_value)
        weight = weight + li.variant.weight
      end
        
      length = 0
      width  = 0
      height = 0
          
      if total <= 5 # padded envelope
        length = 15.5
        width  = 9.5
        height = 6
      elsif total <= 10 # box1
        length = 12
        width  = 8
        height = 5
      else # box2
        length = 20
        width  = 16
        height = 14      
      end
  
      origin = Location.new(:country => 'US', :state => 'AL', :city => 'Tuscaloosa', :zip => '35405')
      destination = Location.new(:country => 'US', :state => order.shipping_address.state, :city => order.shipping_address.city, :postal_code => order.shipping_address.zip)
      packages = [Package.new(weight, [length, width, height], :units => :imperial)]
        
      ups = UPS.new(
        :key => '7CBEA07A8AA3279A',
        :login => 'ABBE FINE',
        :password => '*TuskWear10*',    
        :origin_account => 'A102Y2'
        #:login    => Tuskwear::Application.config.shipping[:ups][:login], 
        #:password => Tuskwear::Application.config.shipping[:ups][:password], 
        #:key      => Tuskwear::Application.config.shipping[:ups][:key]
      )
      response = ups.find_rates(origin, destination, packages)
      
      rates = []	
  	  response.rates.each do |r|
  	    next if r.service_code != '03' && r.service_code !='02'
  	    rates << {
  	      'service_code'    => r.service_code,
  	      'service_name'    => r.service_name,
  	      'total_price'     => r.total_price,
  	      'negotiated_rate' => r.negotiated_rate # - 300
  	    }	    
  	  end
  	  return rates    
    end
    
    # Return the rate for the given service code
    def self.rate(order, service_code)
      self.rates(order).each do |r|
        next if r['service_code'] != service_code
        return r
      end
      return nil	            
    end
    
  end
end
