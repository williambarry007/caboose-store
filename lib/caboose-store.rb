require 'caboose-store/engine'

module CabooseStore
  mattr_accessor :root_url,
    :payment_processor,
    :api_key,
    :smtp_settings,
    :shipping,
    :fulfillment_email,
    :shipping_email,
    :contact_email,
    :payscape_username,
    :payscape_password,
    :authorizenet_login_id,
    :authorizenet_transaction_key,
    :fixed_shipping
end
