
Caboose.Store.Modules.CheckoutStep4 = (function() {

  self = {
    is_confirm: false
  };    
  
  self.initialize = function() {
    $('#checkout-confirm').hide();
    $('#relay').hide();
    self.bind_event_handlers();    
    self.expiration_change_handler();
  };
    
  self.bind_event_handlers = function() {
    $('#checkout-payment form#payment select').change(self.expiration_change_handler);
    $('#checkout-continue button').click(self.continue_handler);
    $('#checkout-confirm #edit_payment').click(self.edit_payment_handler);                
    //$('#relay').on('load', self.relay_handler);
    $(window).on('message', function(event) {
      console.log(event);
    });
  };
    
  self.expiration_change_handler = function(event) {
    var form = $('#checkout-payment #payment')
    month = form.find('select[name=month]').val()
    year = form.find('select[name=year]').val();    
    $('#expiration').val(month + year);
  };
  
  self.continue_handler = function(event) {
    if (!self.is_confirm)
    {
      var cc = $('#billing-cc-number').val();
      if (cc.length < 15)
        $('#message').html("<p class='note error'>Please enter a valid credit card number.</p>");
      else
      {          
        $('#message').empty();
        $('#checkout-payment').hide();
        $('#checkout-confirm').show();
        $('#checkout_nav4 a').removeClass('current').addClass('done');
        $('#checkout_nav5 a').removeClass('not_done').addClass('current');
        $('#confirm_card_number').html("Card ending in " + cc.substr(-4));
        $('#checkout-continue button').html("Confirm order");
        self.is_confirm = true;
      }
    }
    else
    {    
      $('#message').html("<p class='loading'>Processing payment...</p>");
      $('form#payment').submit();
    }
  };
  
  self.edit_payment_handler = function(event) {
    $('#checkout-confirm').hide();
    $('#checkout-payment').show();
    $('#checkout_nav4 a').removeClass('done').addClass('current');
    $('#checkout_nav5 a').removeClass('current').addClass('not_done');
    $('#checkout-continue button').html("Continue");    
    self.is_confirm = false;    
  };
  
  //self.relay_handler = function(event) {
  //  alert('Relay handler');
  //  var iframe = $('#relay');
  //  var form   = $('#payment');
  //  var resp   = iframe.contents().find('#response');
  //  
  //  if (!resp.length || form.length)
  //  {
  //    alert('No response found.');
  //    return false;
  //  }
  //  
  //  resp = JSON.parse(resp.html());    
  //  if (resp.error)
  //    $('#message').html("<p class='note error'>" + resp.error + "</p>");
  //  else if (resp.success == true)
  //    window.location = '/checkout/thanks';                
  //};
  
  return self
}).call(Caboose.Store);

function relay_handler(resp)
{
  console.log('RELAY');
  if (resp.success == true)
    window.location = '/checkout/thanks';
  else if (resp.message)  
    $('#message').html("<p class='note error'>" + resp.message + "</p>");
  else
    $('#message').html("<p class='note error'>There was an error processing your payment.</p>");
}
