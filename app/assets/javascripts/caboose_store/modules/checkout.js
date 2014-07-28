//
// Checkout
//

Caboose.Store.Modules.Checkout = (function() {
  self = {
    templates: {
      address: JST['caboose_store/checkout/address'],
      login: JST['caboose_store/checkout/login'],
      payment: JST['caboose_store/checkout/payment'],
      products: JST['caboose_store/checkout/products'],
      shipping: JST['caboose_store/checkout/shipping'],
      forms: {
        signin: JST['caboose_store/checkout/forms/signin'],
        register: JST['caboose_store/checkout/forms/register']
      }
    }
  };
  
  //
  // Initialize
  //
  
  self.initialize = function() {
    self.$checkout = $('#checkout');
    
    switch (window.location.pathname) {
      case '/checkout':
      case '/checkout/step-one':
        self.step = 1;
        break;
      case '/checkout/step-two':
        self.step = 2;
        break;
    }
    
    self.loggedIn = $('body').data('logged-in');
    self.render();
    
    // Bind events
    self.$checkout.on('click', '[data-login-action]', self.loginClickHandler);
    self.$checkout.on('submit', '#checkout-login form', self.loginSubmitHandler);
    self.$checkout.on('change', 'input[type=checkbox][name=use_as_billing]', self.useAsBillingHandler);
    self.$checkout.on('click', '#checkout-continue button', self.continueHandler);
    self.$checkout.on('change', 'input[type=checkbox][name=shipping]', self.shippingChangeHandler);
    self.$checkout.on('load', '#checkout-payment #relay', self.relayLoadHandler);
    
    window.addEventListener('message', function(event) {
      console.log(event);
      console.log(event.data);
    });
  };
  
  //
  // Event Handlers
  //
  
  self.loginClickHandler = function(event) {
    $section = self.$login.children('section');
    
    switch ($(event.target).data('login-action')) {
      case 'signin':
        $section.empty().html(self.templates.forms.signin());
        break;
      case 'register':
        $section.empty().html(self.templates.forms.register());
        break;
      case 'continue':
        $section.empty();
        break;
    };
  };
  
  self.loginSubmitHandler = function(event) {
    event.preventDefault();
    var $form = $(event.target);
    
    $.ajax({
      type: $form.attr('method'),
      url: $form.attr('action'),
      data: $form.serialize(),
      success: function(response) {
        if (response.error) {
          if ($form.find('.message').length) {
            $form.find('.message').empty().addClass('error').text(response.error);
          } else {
            $form.append($('<span/>').addClass('message error').text(response.error));
          }
        } else {
          self.$login.after($('<p/>').addClass('alert').text('You are now signed in').css('text-align', 'center')).remove();
        }
      }
    });
  };
  
  self.useAsBillingHandler = function(event) {
    if (event.target.checked) {
      self.$address.find('#billing').hide();
    } else {
      self.$address.find('#billing').show();
    }
  };
  
  self.continueHandler = function(event) {
    $form = self.$address.find('form');
    
    $.ajax({
      type: $form.attr('method'),
      url: $form.attr('action'),
      data: $form.serialize(),
      success: function(response) {
        if (response.success) {
          window.location = '/checkout/step-two';
        } else {
          $form.find('.message').remove();
          $form.find('#' + response.address + ' h3').append($('<span/>').addClass('message error').text(response.errors[0]));
        }
      }
    });
  };
  
  self.shippingChangeHandler = function(event) {
    console.log('update shipping method');
  };
  
  self.relayLoadHandler = function(event) {
    console.log('RELAY');
    //response = JSON.parse($(event.target).contents().find('#response').html());
    //console.log(response);
  };
  
  //
  // Render
  //
  
  self.render = function() {
    self.$products = self.$checkout.find('#checkout-products');
    self.renderProducts();
    
    if (self.step == 1) {
      self.$login = self.$checkout.find('#checkout-login');
      self.$address = self.$checkout.find('#checkout-address');
      
      if (!loggedIn) {
        self.$login.html(self.templates.login());
      } else {
        self.$login.remove();
      }
      
      //self.$address.html(self.templates.address({  states: window.States }));
      self.renderAddress();
    } else {
      self.$shipping = self.$checkout.find('#checkout-shipping');
      self.$payment = self.$checkout.find('#checkout-payment');
      
      self.renderShipping();
      self.renderPayment();
    }
  };
  
  self.renderProducts = function() {
    if (!self.$products.length) return false;
    
    $.get('/cart/items.json', function(response) {
      self.$products.empty().html(self.templates.products({ order: response.order }));
    });
  };
  
  self.renderAddress = function() {
    if (!self.$address.length) return false;
    
    $.get('/checkout/address', function(response) {
      self.$address.empty().html(self.templates.address({
        shippingAddress: response.shipping_address,
        billingAddress: response.billing_address,
        states: window.States
      }));
    });
  };
  
  self.renderShipping = function() {
    if (!self.$shipping.length) return false;
    
    $.get('/checkout/shipping', function(response) {
      if (response.fixed_shipping) return false;
      self.$shipping.empty().html(self.templates.shipping({ rates: response.rates }));
    });
  };
  
  self.renderPayment = function() {
    if (!self.$payment.length) return false;
    
    $.get('/checkout/payment', function(response) {
      self.$payment.empty().html(self.templates.payment({ form: response }));
    });
  };
  
  return self
}).call(Caboose.Store);

