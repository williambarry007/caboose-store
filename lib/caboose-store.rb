require "caboose-store/engine"

module CabooseStore

  # The credit card payment processor.
  # Must extend from CabooseStore::PaymentProcessors::Base  
  mattr_accessor :payment_processor
  @@payment_processor = "CabooseStore::PaymentProcessors::Authorizenet"

end

