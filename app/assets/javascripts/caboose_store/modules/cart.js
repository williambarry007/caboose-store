//
// Cart
//

Caboose.Store.Modules.Cart = (function() {
  var self = {};
  
  //
  // Initialize
  //
  
  self.initialize = function() {
    $('[caboose-cart=add]').on('submit', self.addHandler);
    $('[caboose-cart=open]').on('click', self.open);
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
            self.open();
          } else {
            alert(response.errors[0]);
          }
        }
      });
    }
  };
  
  self.updateHandler = function(event) {
    var $input = $(event.target);
    
    $.ajax({
      type: 'put',
      url: '/cart/items/' + $input.data('id'),
      data: { quantity: $input.val() },
      success: function(response) {
        if (response.success) {
          $input.parents('tr').find('.price').empty().text(response.line_item.price);
        } else {
          alert(response.errors[0]);
        }
      }
    });
  };
  
  self.removeHandler = function(event) {
    var $button = $(event.target);
    
    $.ajax({
      type: 'delete',
      url: '/cart/items/' + $(event.target).data('id'),
      success: function(response) {
        if (response.success) {
          if ($button.parents('tbody').children('tr').length > 1) {
            $button.parents('tr').remove();
          } else {
            self.close();
          }
        } else {
          alert(response.errors[0]);
        }
      }
    });
  };
  
  self.redirectHandler = function(event) {
    event.preventDefault();
    window.location = $(event.target).attr('href');
  };
  
  //
  // Modal Methods
  //
  
  self.open = function() {
    $.colorbox({
      href: '/modal',
      iframe: true,
      innerWidth: 600,
      innerHeight: 400,
      onComplete: function() {
        $.get('/cart/items.json', function(response) {
          var $iframe = $('#cboxLoadedContent iframe');
          
          $iframe.load(function() {
            var $container = $iframe.contents().find('#modal_content')
              , content = JST['caboose_store/cart/index']({ order: response.order });
            console.log($container);
            $container.html(content);
            $container.find('[caboose-cart=close]').on('click', self.close);
            $container.find('[caboose-cart=update]').on('change', self.updateHandler);
            $container.find('[caboose-cart=remove]').on('click', self.removeHandler);
            $container.find('[caboose-cart=redirect]').on('click', self.redirectHandler);
          });
        });
      }
    });
  };
  
  self.close = function() {
    $.colorbox.close();
  };
  
  return self;
}).call(Caboose.Store);

