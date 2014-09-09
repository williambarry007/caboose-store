class CabooseStore::PaymentProcessors::Authorizenet < CabooseStore::PaymentProcessors::Base
  def self.api(root, body, test=false)
  end
  
  def self.form_url(order=nil)
    #if Rails.env == 'development'
    'https://test.authorize.net/gateway/transact.dll'
    #else
    #  'https://secure.authorize.net/gateway/transact.dll'
    #end
  end
  
  def self.authorize(order, params)
  end
  
  def self.void(order)
  end
  
  def self.capture(order)
  end
  
  def self.refund(order)
  end
end
