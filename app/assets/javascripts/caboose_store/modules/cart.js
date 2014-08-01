//
// Cart
//

Caboose.Store.Modules.Cart = (function() {
  var self = {
    templates: {
      lineItems: JST['caboose_store/cart/line_items']
    }
  };
  
  //
  // Initialize
  //
  
  self.initialize = function() {
    $('[caboose-cart=add]').on('submit', self.addHandler);
    self.$cart = $('#cart');
    if (!self.$cart.length) return false;
    self.$cart.on('click', '[caboose-cart=remove]', self.removeHandler);
    self.$cart.on('keyup', 'input', self.updateHandler);
    self.render();
  };
  
  //
  // Render
  //
  
  self.render = function() {
    $.get('/cart/items', function(response) {
      self.$cart.empty().html(self.templates.lineItems({ order: response.order }));
    });
  };
  
  //
  // Event Handlers
  //
  
  self.addHandler = function(event) {
    event.preventDefault();
    
    var $form = $(event.target);
    
    if ($form.find('input[name=variant_id]').val().trim() == "") {
      alert('Must select all options');
    } else if (parseInt($form.find('input[name=quantity]').val()) <= 0) {
      alert('Quantity must be 1 or more');
    } else {
      $.ajax({
        type: $form.attr('method'),
        url: $form.attr('action'),
        data: $form.serialize(),
        success: function(response) {
          if (response.success) {
            console.log(response);
            if (response.new_cart_items.length == 0) return false;
            var $link = $('[caboose-cart=link]');
            
            if ($link.children('i').length) {
              $link.children('i').empty().text(response.new_cart_items.length);
            } else {
              $link.append($('<i/>').text(response.new_cart_items.length));
            }
          } else {
            alert(response.errors[0]);
          }
        }
      });
    }
  };
  
  self.updateHandler = function(event) {
    var $quantity = $(event.target)
      , $lineItem = $quantity.parents('li').first();
      
    $quantity.val($quantity.val().match(/\d*\.?\d+/));
    
    delay(function() {
      $.ajax({
        type: 'put',
        url: '/cart/items/' + $lineItem.data('id'),
        data: { quantity: $quantity.val() },
        success: function(response) {
          if (response.success) {
            $lineItem.find('.price').empty().text('$' + response.line_item.price);
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

