require 'active_shipping'
include ActiveMerchant::Shipping

module CabooseStore
  class ShippingCalculator
    def self.rates(order)
      return [] if CabooseStore::shipping.nil?
      
      total  = 0.0
      weight = 0.0
      
      order.line_items.each do |li|
        total  = total + (li.variant.shipping_unit_value.nil? ? 0 : li.variant.shipping_unit_value)
        weight = weight + (li.variant.weight || 0)
      end
      
      length = 0
      width  = 0
      height = 0
      
      if total <= 5
        length = 15.5
        width  = 9.5
        height = 6
      elsif total <= 10
        length = 12
        width  = 8
        height = 5
      else
        length = 20
        width  = 16
        height = 14
      end
      
      origin = Location.new(
        :country => CabooseStore::shipping[:origin][:country],
        :state   => CabooseStore::shipping[:origin][:state],
        :city    => CabooseStore::shipping[:origin][:city],
        :zip     => CabooseStore::shipping[:origin][:zip]
      )
      
      destination = Location.new(
        :country     => CabooseStore::shipping[:origin][:country],
        :state       => order.shipping_address.state,
        :city        => order.shipping_address.city,
        :postal_code => order.shipping_address.zip
      )
      
      packages = [Package.new(weight, [length, width, height], :units => :imperial)]
      
      ups = UPS.new(
        :key            => CabooseStore::shipping[:ups][:key],
        :login          => CabooseStore::shipping[:ups][:username],
        :password       => CabooseStore::shipping[:ups][:password],
        :origin_account => CabooseStore::shipping[:ups][:origin_account]
      )
      
      ups_response = ups.find_rates(origin, destination, packages)
      
      rates = ups_response.rates.collect do |rate|
        next if CabooseStore::allowed_shipping_method_codes && !CabooseStore::allowed_shipping_method_codes.index(rate.service_code)
        
        {
          :service_code    => rate.service_code,
          :service_name    => rate.service_name,
          :total_price     => rate.total_price.to_d / 100,
          :negotiated_rate => rate.negotiated_rate
        }
      end
      
      return rates.compact
    end
    
    def self.rate(order)
      return nil if !order.shipping_method_code
      self.rates(order).each { |rate| return rate if rate[:service_code] == order.shipping_method_code }
      return nil
    end
  end
end

