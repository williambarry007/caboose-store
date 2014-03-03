//
// Cart
//
// :: Initialize
// :: Open
// :: Close
// :: Add
// :: Update
// :: Remove

var CabooseCart = function() {
	var self = this;
	
	//
	// Initialize
	//
	
	self.initialize = function() {
		$.ajax({
			url: '/cart/items',
			type: 'get',
			success: function(response) {
				self.items = response;
				
				// Emit ready event
				Caboose.events.trigger('cart.ready');
				
				// Open cart
				$('[caboose-cart=open]').on('click', function(event) {
					event.preventDefault();
					self.open( $(window).width() < 1024 );
				});
				
				// Add to cart from button
				$('[caboose-cart=add]').not('form').on('click', function(event) {
					event.preventDefault();
					self.add( $(event.target).data('id') );
					self.open();
				});
				
				// Add to cart from form
				$('form[caboose-cart=add]').on('submit', function(event) {
					event.preventDefault();
					
					var data = $(event.delegateTarget).serializeArray()
						, json = _.object( _.pluck(data, 'name'), _.pluck(data, 'value') );
					
					self.add(json);
					self.open();
				});
			}
		});
	};
	
	//
	// Open
	//
	
	self.open = function(mobile) {
		if (mobile) window.location.href = '/mobile/cart/items';
		
		$.colorbox({
			href: '/modal',
			iframe: true,
			innerWidth: 600,
			innerHeight: 400,
			
			onComplete: function() {
				$("#cboxLoadedContent iframe").load(function() {
					var $container = $(this).contents().find('#modal_content')
						, content    = JST['caboose_store/cart/index']({items: self.items});
						
					// Inject content into modal
					$container.html(content);
					
					// Close cart
					$container.find('[caboose-cart=close]').on('click', function(event) {
						event.preventDefault();
						self.close();
					});
					
					// Redirect user
					$container.find('[caboose-cart=redirect]').on('click', function(event) {
						event.preventDefault();
						window.location = event.target.href;
					});
					
					// Update item from button
					$container.find('[caboose-cart=update]').not('form').on('change', function(event) {
						var $target    = $(event.target)
							, id         = $target.data('id')
							, attribute  = $target.attr('name')
							, value      = $target.val()
							, attributes = {};
							
						attributes[attribute] = value;
						self.update(id, attributes);
					});
					
					// Update item from form
					$container.find('form[caboose-cart=update]').on('submit', function(event) {
						event.preventDefault();
						
						var $target    = $(event.delegateTarget)
							, id         = $target.data('id')
							, form       = $target.serializeArray()
							, attributes = _.object( _.pluck(form, 'name'), _.pluck(form, 'value') );
						
						self.update(id, attributes);
					});
					
					// Remove from cart
					$container.find('[caboose-cart=remove]').on('click', function(event) {
						event.preventDefault();
						var id = $(event.target).data('id');
						
						self.remove(id, function() {
							if (self.items.length == 0) {
								self.close();
							} else {
								$container.find('[caboose-cart=remove][data-id=' + id + ']').parents('tr').remove();
							}
						});
					});
					
					$container.find('table').css('width', '100%');
				});
				
			  $("#cboxTopLeft"      ).css('background', '#111');
			  $("#cboxTopRight"     ).css('background', '#111');
			  $("#cboxBottomLeft"   ).css('background', '#111');
			  $("#cboxBottomRight"  ).css('background', '#111');
			  $("#cboxMiddleLeft"   ).css('background', '#111');
			  $("#cboxMiddleRight"  ).css('background', '#111');
			  $("#cboxTopCenter"    ).css('background', '#111');
			  $("#cboxBottomCenter" ).css('background', '#111');
			  $("#cboxClose"        ).hide();
			}
		});
	};
	
	//
	// Close
	//
	
	self.close = function() {
		$.colorbox.close();
	};
	
	//
	// Add
	//
	
	self.add = function(something, callback) {
		var id   = _.isNumber(something) ? something : ''
			, data = _.isObject(something) ? something : {};
			
		$.ajax({
			url: '/cart/item/' + id,
			type: 'post',
			data: data,
			success: function(response) {
				
				if (response.error) {
					alert(response.error);
				} else {
					
					// If item exists increment quantity, otherwise add to cart
					if ( _.contains(_.pluck(self.items, 'id'), response.id) ) {
						_.find(self.items, function(item) { return item.id == response.id }).quantity = response.quantity;
					} else {
						self.items.push(response);
					}
				}
				
				if (callback) callback(response);
			}
		});
	};
	
	//
	// Update
	//
	
	self.update = function(id, attributes, callback) {
		$.ajax({
			url: '/cart/item/' + id,
			type: 'put',
			data: {attributes: attributes},
			success: function(response) {
				
				// Update cart item quantity
				_.find(self.items, function(item) { return item.id == response.id }).quantity = response.quantity;
				
				if (callback) callback(response);
			}
		});
	};
	
	//
	// Remove
	//
	
	self.remove = function(id, callback) {
		$.ajax({
			url: '/cart/item/' + id,
			type: 'delete',
			success: function(response) {
				self.items = _.reject(self.items, function(item) { return item.id == response.id });
				if (callback) callback(response);
			}
		});
	};
	
	// Init and return
	$(document).ready(self.initialize);
	return self;
};

Caboose.Cart = new CabooseCart();
