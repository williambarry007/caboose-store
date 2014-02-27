require "rexml/document"

class CabooseStore::PaymentProcessors::Payscape < CabooseStore::PaymentProcessors::Base
  def self.api(root, body, test=false)
    
    # Determine if transaction should be a test
    body['api-key'] = if test or Rails.env == 'development'
      '2F822Rw39fx762MaV7Yy86jXGTC7sCDy'
    else
      CabooseStore::ApiKey
    end
    
    uri                  = URI.parse('https://secure.payscapegateway.com/api/v2/three-step')
    http                 = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl         = true
    request              = Net::HTTP::Post.new(uri.path)
    request.content_type = 'text/xml'
    request.body         = body.to_xml({root: root})
    xml_response         = http.request(request)
    document             = REXML::Document.new(xml_response.body.to_s)
    response             = Hash.new
    
    document.root.elements.each { |element| response[element.name] = element.text }
    ap response
    return response
  end
  
  def self.form_url(order)
    response = self.api 'auth', {
      'redirect-url' => "#{CabooseStore::RootUrl}/checkout/relay/#{order.id}",
      'amount'       => order.total.to_s,
      'billing'      => {
        'first-name' => order.billing_address.first_name,
        'last-name'  => order.billing_address.last_name,
        'address1'   => order.billing_address.address1,
        'address2'   => order.billing_address.address2,
        'city'       => order.billing_address.city,
        'state'      => order.billing_address.state,
        'postal'     => order.billing_address.zip
      }
    }, order.test?
    
    order.transaction_id = response['transaction-id']
    order.transaction_service = 'payscape'
    order.save
    
    return response['form-url']
  end
  
  def self.authorize(order, params)
    response = self.api 'complete-action', { 'token-id' => params[:token_id] }, order.test?
    return response['result-code'].to_i == 100
  end
  
  def self.void(order)
    response = self.api 'void', { 'transaction-id' => order.transaction_token.to_s }, order.test?
    return response['result-code'].to_i == 100
  end
  
  def self.capture(order)
    response = self.api 'capture', { 'transaction-id' => order.transaction_id.to_s }, order.test?
    return response['result-code'].to_i == 100
  end
  
  def self.refund(order)
    response = self.api 'refund', {
      'transaction-id' => order.transaction_id.to_s,
      'amount'         => order.total.to_s
    }, order.test?
    
    return response['result-code'].to_i == 100
  end
end
