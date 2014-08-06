//
// Checkout
//

Caboose.Store.Modules.Checkout = (function() {
  self = {
    templates: {
      address: JST['caboose_store/checkout/address'],
      login: JST['caboose_store/checkout/login'],
      payment: JST['caboose_store/checkout/payment'],
      lineItems: JST['caboose_store/checkout/line_items'],
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
    switch (window.location.pathname.replace(/\/$/, "")) {
      case '/checkout':
      case '/checkout/step-one':
        self.step = 1;
        break;
      case '/checkout/step-two':
        self.step = 2;
        break;
    }
    
    self.$checkout = $('#checkout')
    if (!self.$checkout.length) return false;
    self.loggedIn = $('body').data('logged-in');
    self.fetch(self.render);
    self.bindEventHandlers();
  };
  
  //
  // Fetch
  //
  
  self.fetch = function(callback) {
    $.get('/cart/items', function(response) {
      self.order = response.order
      
      if (self.step == 2) {
        $.get('/checkout/shipping', function(response) {
          self.shippingRates = response.rates;
          self.selectedRate = response.selected_rate;
          callback();
        });
      } else {
        callback();
      }
    });
  };
  
  //
  // Events
  //
  
  self.bindEventHandlers = function() {
    self.$checkout.on('click', '[data-login-action]', self.loginClickHandler);
    self.$checkout.on('submit', '#checkout-login form', self.loginSubmitHandler);
    self.$checkout.on('change', 'input[type=checkbox][name=use_as_billing]', self.useAsBillingHandler);
    self.$checkout.on('click', '#checkout-continue button', self.continueHandler);
    self.$checkout.on('click', '#checkout-complete button', self.completeHandler);
    self.$checkout.on('change', '#checkout-shipping select', self.shippingChangeHandler);
    self.$checkout.on('change', '#checkout-payment form#payment select', self.expirationChangeHandler);
    self.$checkout.on('submit', '#checkout-payment form#payment', self.paymentSubmitHandler);
    self.$checkout.on('load', '#checkout-payment iframe#relay', self.relayLoadHandler);
    $(window).on('message', self.relayHandler);
  };
  
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
          $.post('/checkout/attach-user', function(response) {
            console.log(response);
          });
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
    if (event.target.value == "") return false;
    
    $.ajax({
      url: '/checkout/shipping',
      type: 'put',
      data: { shipping_code: event.target.value },
      success: function(response) {
        if (response.success) {
          self.order = response.order;
          self.renderLineItems();
          self.renderPayment();
        }
      }
    });
  };
  
  self.expirationChangeHandler = function(event) {
    var $form = $('#checkout-payment #payment')
      , month = $form.find('select[name=month]').val()
      , year = $form.find('select[name=year]').val();
    
    $form.find('#expiration').val(month + year);
  };
  
  self.completeHandler = function(event) {
    if (self.$payment.length) self.$payment.find('form').submit();
  };
  
  self.paymentSubmitHandler = function(event) {
    event.preventDefault();
    
    if (!self.order.shipping_code) {
      alert('Please choose a shipping method');
    } else {
      self.$checkout.off('submit', '#checkout-payment form#payment');
      $(event.target).addClass('loading').submit();
    }
  };
  
  self.relayHandler = function(event) {
    console.log('RELAY');
    var data = event.originalEvent.data
      , $form = $('#checkout #checkout-payment #payment');
    console.log(data);
    if (!$form.length) return false;
    
    if (data.success == true) {
      window.location = '/checkout/thanks';
    } else {
      if ($form.find('.message').length) {
        $form.find('.message').empty().text(data.message);
      } else {
        $form.append($('<span/>').addClass('message error').text(data.message));
      }
      
      $form.removeClass('loading');
    }
  };
  
  //
  // Render
  //
  
  self.render = function() {
    self.$checkout.find('.loading').remove();
    self.renderLineItems();
    
    if (self.step == 1) {
      self.renderLogin();
      self.renderAddress();
    } else {
      self.renderShipping();
      self.renderPayment();
    }
  };
  
  self.renderLineItems = function() {
    self.$lineItems = self.$checkout.find('#checkout-line-items');
    if (!self.$lineItems.length) return false;
    self.$lineItems.empty().html(self.templates.lineItems({ order: self.order }));
  };
  
  self.renderLogin = function() {
    self.$login = self.$checkout.find('#checkout-login');
    if (self.loggedIn) self.$login.remove();
    if (self.loggedIn || !self.$login.length) return false;
    self.$login.html(self.templates.login());
  };
  
  self.renderAddress = function() {
    self.$address = self.$checkout.find('#checkout-address');
    if (!self.$address.length) return false;
    
    self.$address.empty().html(self.templates.address({
      shippingAddress: self.order.shipping_address,
      billingAddress: self.order.billing_address,
      states: window.States
    }));
  };
  
  self.renderShipping = function() {
    self.$shipping = self.$checkout.find('#checkout-shipping');
    if (!self.$shipping.length) return false;
    
    self.$shipping.empty().html(self.templates.shipping({
      rates: self.shippingRates,
      selectedRate: self.selectedRate
    }));
  };
  
  self.renderPayment = function() {
    self.$payment = self.$checkout.find('#checkout-payment');
    if (!self.$payment.length) return false;
    self.$checkout.addClass('loading');
    
    $.get('/checkout/payment', function(response) {
      self.$payment.empty().html(self.templates.payment({ form: response }));
      self.expirationChangeHandler();
      self.$checkout.removeClass('loading');
    });
  };
  
  return self
}).call(Caboose.Store);

