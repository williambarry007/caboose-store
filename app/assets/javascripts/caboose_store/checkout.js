//
// Checkout
//
// :: Initialize
// :: Index
// :: Shipping
// :: Payment

var CabooseCheckout = function() {
	var self = this;
	
	//
	// Initialize
	//
	
	self.initialize = function() {
		
		// Ensure that a user is logged in
		if (!Caboose.loggedIn) Caboose.login();
		
		// Route to correct method
		switch (window.location.pathname) {
			case '/checkout':          self.index();    break;
			case '/checkout/shipping': self.shipping(); break;
			case '/checkout/billing':  self.billing();  break;
		}
	};
	
	//
	// Index
	//
	
	self.index = function() {
		
		// Ensure use as billing is automatically checked
		$('#use-as-billing').prop('checked', true);
		
		// Show/hide the billing form
		$('#use-as-billing').on('change', function(event) {
			if ($('#use-as-billing')[0].checked) {
				$('#billing').hide()
			} else {
				$('#billing').show()
			}
		});
		
		// Update address info
		$('form#address').on('submit', function(event) {
			event.preventDefault();
			
			$.ajax({
				url: '/checkout/address',
				type: 'put',
				data: $(event.delegateTarget).serialize(),
				success: function(response) {
					if (response.error)    $('#message').html("<p class='note error'>" + response.error + "</p>");
					if (response.redirect) window.location = response.redirect;
				}
			});
		});
	};
	
	//
	// Shipping
	//
	
	self.shipping = function() {
		$('form#shipping-rates').on('submit', function(event) {
			event.preventDefault();
			
			var $form = $(event.delegateTarget)
				, code  = $('input[name=shipping_method_code]:checked', $form).val()
				, name  = $('input#shipping-method-' + code + '-name', $form).val()
				, price = $('input#shipping-method-' + code + '-price', $form).val();
				
			$.ajax({
				url: '/checkout/shipping-method',
				type: 'put',
				data: {
					shipping_method: {
						code: code,
						name: name,
						price: price
					}
				},
				success: function(response) {
					if (response.error)    $('#message').html("<p class='note error'>" + response.error + "</p>");
					if (response.redirect) window.location = response.redirect;
				}
			});
		});
	};
	
	//
	// Payment
	//
	
	self.billing = function() {
		$('#billing-expiration-month, #billing-expiration-year').on('change', function(event) {
			$('input[name=billing-cc-exp]').val($('#billing-expiration-month').val() + $('#billing-expiration-year').val());
		});
		
		$('#billing-form').one('submit', function(e) {
			e.preventDefault();
			
			$('input[name=billing-cc-exp]').val($('#billing-expiration-month').val() + $('#billing-expiration-year').val());
			
			var $form    = $(e.delegateTarget)
				, cc_num   = $form.find('input[name=billing-cc-number]').val()
				, cc_exp   = $form.find('input[name=billing-cc-exp]').val()
				, total    = $('input#billing-amount').val()
				, $confirm = $('</p>');
			
			$confirm.append( $('</p>').attr('style', 'margin-bottom: 0').html('<strong>Credit Card Number</strong>: xxxx-xxxx-xxxx-' + cc_num.replace(/\-\ /g, '').substr(-4)) );
			$confirm.append( $('</p>').attr('style', 'margin-bottom: 0').html('<strong>Expiration Date</strong>: ' + cc_exp.substr(0, 2) + '/' + cc_exp.substr(2, 2)) );
			$confirm.append( $('</p>').html('<strong>Total</strong>: $' + total) );
			$confirm.append( $('</p>').html('<a href="/checkout/billing">Edit billing info</a>') );
			$confirm.append( $('</p>').html('<input id="submit-billing" type="button" value="Continue >" />') );
			
			$form.after($confirm);
			$form.hide();
			
			$confirm.find('#submit-billing').on('click', function(e) {
				e.preventDefault();
				$form.submit();
			});
		});
	};
	
	// Init and return
	$(document).ready(self.initialize);
	return self;
};

Caboose.Checkout = new CabooseCheckout();
