//
// Cart
//

Caboose.Store.Modules.Cart = (function() {
  var self = {
    templates: {
      lineItems: JST['caboose_store/cart/line_items'],
      addToCart: JST['caboose_store/cart/add_to_cart']
    }
  };
  
  //
  // Initialize
  //
  
  self.initialize = function() {
    self.renderAddToCart();
    self.$cart = $('#cart');
    if (!self.$cart.length) return false;
    self.$cart.on('click', '[caboose-cart=remove]', self.removeHandler);
    self.$cart.on('keyup', 'input', self.updateHandler);
    self.render();
  };
  
  //
  // Set Variant
  //
  
  self.setVariant = function(variant) {
    if (self.$addToCart) self.$addToCart.find('input[name=variant_id]').val(variant ? variant.id : "");
  };
  
  //
  // Render
  //
  
  self.render = function() {
    $.get('/cart/items', function(response) {
      self.$cart.empty().html(self.templates.lineItems({ order: response.order }));
    });
  };
  
  self.renderAddToCart = function() {
    self.$addToCart = $('#add-to-cart');
    if (!self.$addToCart.length) return false;
    self.$addToCart.empty().html(self.templates.addToCart());
    $('input[name=quantity]', self.$addToCart).on('keyup', self.quantityKeyupHandler);
    $('form', self.$addToCart).on('submit', self.addHandler);
  };
  
  //
  // Event Handlers
  //
  
  self.quantityKeyupHandler = function(event) {
    var $quantity = $(event.target);
    $quantity.val($quantity.val().match(/\d*\.?\d+/));
  };
  
  self.addHandler = function(event) {
    event.preventDefault();
    var $form = $(event.target);
    
    if ($form.find('input[name=variant_id]').val().trim() == "") {
      alert('Must select all options');
    } else {
      $.ajax({
        type: $form.attr('method'),
        url: $form.attr('action'),
        data: $form.serialize(),
        success: function(response) {
          if (!response.success) alert(response.errors[0]);
        }
      });
    }
  };
  
  self.updateHandler = function(event) {
    var $quantity = $(event.target)
      , $lineItem = $quantity.parents('li').first();
    
    $quantity.val($quantity.val().match(/\d*\.?\d+/));
    if ($quantity.val() == "") return false;
    
    delay(function() {
      $.ajax({
        type: 'put',
        url: '/cart/items/' + $lineItem.data('id'),
        data: { quantity: $quantity.val() },
        success: function(response) {
          if (response.success) {
            $lineItem.find('.price').empty().text('$' + response.line_item.price);
            if (self.$cart.find('.subtotal').length) self.$cart.find('.subtotal').empty().text('$' + response.order_subtotal);
          } else {
            alert(response.errors[0]);
          }
        }
      });
    }, 1000);
  };
  
  self.removeHandler = function(event) {
    var $lineItem = $(event.target).parents('li').first();
    
    $.ajax({
      type: 'delete',
      url: '/cart/items/' + $lineItem.data('id'),
      success: function(response) {
        if (response.success) self.render();
      }
    });
  };
  
  self.redirectHandler = function(event) {
    event.preventDefault();
    window.location = $(event.target).attr('href');
  };
  
  return self;
}).call(Caboose.Store);

