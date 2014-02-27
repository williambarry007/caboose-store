require "caboose-store/engine"

module CabooseStore

  # The credit card payment processor.
  # Must extend from CabooseStore::PaymentProcessors::Base  
  # mattr_accessor :payment_processor
  # @@payment_processor = "CabooseStore::PaymentProcessors::Authorizenet"
  
  mattr_accessor :root_url, :payment_processor, :api_key, :smtp_settings, :shipping,
    :fulfillment_email, :shipping_email
  
end

