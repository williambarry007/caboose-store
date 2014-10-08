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
    :authorize_net_login_id,
    :authorize_net_transaction_key,
    :handling_percentage,
    :allowed_shipping_method_codes,
    :default_shipping_method_code,
    :from_address
end

