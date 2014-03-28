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
    def self.rates(order, service_code=nil)
      total  = 0.0
      weight = 0.0
      
      # Get total and weight from order
      order.line_items.each do |li|
        total  = total + (li.variant.shipping_unit_value.nil? ? 0 : li.variant.shipping_unit_value)
        weight = weight + (li.variant.weight || 0)
      end
      
      # Figure out package dimensions
      
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
      
      # Set origin
      origin = Location.new(
        :country => CabooseStore::shipping[:origin][:country],
        :state   => CabooseStore::shipping[:origin][:state],
        :city    => CabooseStore::shipping[:origin][:city],
        :zip     => CabooseStore::shipping[:origin][:zip]
      )
      
      # Set destination
      destination = Location.new(
        :country     => CabooseStore::shipping[:origin][:country],
        :state       => order.shipping_address.state,
        :city        => order.shipping_address.city,
        :postal_code => order.shipping_address.zip
      )
      
      # Generate package array
      packages = [Package.new(weight, [length, width, height], units: :imperial)]
      
      # Generate UPS object
      ups = UPS.new(
        :key            => CabooseStore::shipping[:ups][:key],
        :login          => CabooseStore::shipping[:ups][:username],
        :password       => CabooseStore::shipping[:ups][:password],
        :origin_account => CabooseStore::shipping[:ups][:origin_account]
      )
      
      # Get response from UPS
      ups_response = ups.find_rates(origin, destination, packages)
      
      # Array to hold all rates
      rates = Array.new
      
      ups_response.rates.each do |rate|
        next if rate.service_code != '03' && rate.service_code !='02'
        
        rates << {
          'service_code'    => rate.service_code,
          'service_name'    => rate.service_name,
          'total_price'     => rate.total_price,
          'negotiated_rate' => rate.negotiated_rate # - 300
        }
      end
      
      return rates
    end
    
    # Return the rate for the given service code
    def self.rate(order, service_code)
      
      # Attempt to return rate
      self.rates(order).each { |rate| return rate if rate['service_code'] == service_code }
      
      # If all else fails return nil
      return nil
    end
  end
end
